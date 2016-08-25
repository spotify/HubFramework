#import "HUBComponentWrapperImplementation.h"

#import "HUBComponentWithChildren.h"
#import "HUBComponentWithRestorableUIState.h"
#import "HUBComponentViewObserver.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentContentOffsetObserver.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBComponentUIStateManager.h"
#import "HUBComponentResizeObservingView.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapperImplementation () <HUBComponentChildDelegate, HUBComponentResizeObservingViewDelegate>

@property (nonatomic, strong, readwrite) id<HUBComponentModel> model;
@property (nonatomic, strong, readonly) id<HUBComponent> component;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, weak, nullable) HUBComponentWrapperImplementation *parentComponentWrapper;
@property (nonatomic, assign) BOOL preparedForReuse;

@end

@implementation HUBComponentWrapperImplementation

- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager
                         delegate:(id<HUBComponentWrapperDelegate>)delegate
           parentComponentWrapper:(nullable HUBComponentWrapperImplementation *)parentComponentWrapper
{
    NSParameterAssert(component != nil);
    NSParameterAssert(model != nil);
    NSParameterAssert(UIStateManager != nil);
    NSParameterAssert(delegate != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _model = model;
        _component = component;
        _UIStateManager = UIStateManager;
        _delegate = delegate;
        _parentComponentWrapper = parentComponentWrapper;
        _preparedForReuse = YES;

        if ([_component conformsToProtocol:@protocol(HUBComponentWithChildren)]) {
            ((id<HUBComponentWithChildren>)_component).childDelegate = self;
        }
    }
    
    return self;
}

#pragma mark - API

- (void)updateViewForChangedContentOffset:(CGPoint)contentOffset
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        return;
    }
    
    [(id<HUBComponentContentOffsetObserver>)self.component updateViewForChangedContentOffset:contentOffset];
}

#pragma mark - Property overrides

- (BOOL)handlesImages
{
    return [self.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)];
}

- (BOOL)isContentOffsetObserver
{
    return [self.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)];
}

- (BOOL)isRootComponent
{
    return self.parentComponentWrapper == nil;
}

#pragma mark - HUBComponent

- (NSSet<HUBComponentLayoutTrait *> *)layoutTraits
{
    return self.component.layoutTraits;
}

- (nullable __kindof UIView *)view
{
    return self.component.view;
}

- (void)setView:(nullable __kindof UIView *)view
{
    self.component.view = view;
}

- (void)loadView
{
    BOOL const viewLoaded = (self.view != nil);
    UIView * const view = HUBComponentLoadViewIfNeeded(self.component);
    
    if (!viewLoaded) {
        if ([self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
            HUBComponentResizeObservingView * const resizeObservingView = [[HUBComponentResizeObservingView alloc] initWithFrame:view.bounds];
            resizeObservingView.delegate = self;
            [view addSubview:resizeObservingView];
        }
    }
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return [self.component preferredViewSizeForDisplayingModel:model containerViewSize:containerViewSize];
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    self.model = model;
    
    if (!self.preparedForReuse) {
        [self prepareForReuseAndSendToReusePool:NO];
    }
    
    [self.component configureViewWithModel:model containerViewSize:containerViewSize];
    [self restoreComponentUIStateForModel:model];
    
    self.preparedForReuse = NO;
}

- (void)prepareViewForReuse
{
    [self prepareForReuseAndSendToReusePool:YES];
}

#pragma mark - HUBComponentWithImageHandling

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)]) {
        return CGSizeZero;
    }
    
    return [(id<HUBComponentWithImageHandling>)self.component preferredSizeForImageFromData:imageData
                                                                                      model:model
                                                                          containerViewSize:containerViewSize];
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model animated:(BOOL)animated
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithImageHandling)]) {
        return;
    }
    
    [(id<HUBComponentWithImageHandling>)self.component updateViewForLoadedImage:image
                                                                       fromData:imageData
                                                                          model:model
                                                                       animated:animated];
}

#pragma mark - HUBComponentViewObserver

- (void)viewWillAppear
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
        return;
    }
    
    [(id<HUBComponentViewObserver>)self.component viewWillAppear];
}

- (void)viewDidResize
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
        return;
    }
    
    [(id<HUBComponentViewObserver>)self.component viewDidResize];
}

#pragma mark - HUBComponentChildDelegate

- (id<HUBComponent>)component:(id<HUBComponentWithChildren>)component childComponentForModel:(id<HUBComponentModel>)childComponentModel
{
    id<HUBComponent> const childComponent = [self.delegate componentWrapper:self childComponentForModel:childComponentModel];
    return childComponent;
}

- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self childComponentWithView:childView willAppearAtIndex:childIndex];
}

- (void)component:(id<HUBComponentWithChildren>)component didStopDisplayingChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self childComponentWithView:childView didDisappearAtIndex:childIndex];
}

- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self childComponentWithView:childView selectedAtIndex:childIndex];
}

#pragma mark - HUBComponentResizeObservingViewDelegate

- (void)resizeObservingViewDidResize:(HUBComponentResizeObservingView *)view
{
    [(id<HUBComponentViewObserver>)self.component viewDidResize];
}

#pragma mark - Private utilities

- (void)saveComponentUIState
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id currentUIState = [(id<HUBComponentWithRestorableUIState>)self.component currentUIState];
    
    if (currentUIState == nil) {
        [self.UIStateManager removeSavedUIStateForComponentModel:self.model];
    } else {
        [self.UIStateManager saveUIState:currentUIState forComponentModel:self.model];
    }
}

- (void)restoreComponentUIStateForModel:(id<HUBComponentModel>)model
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id restoredUIState = [self.UIStateManager restoreUIStateForComponentModel:model];
    
    if (restoredUIState != nil) {
        [(id<HUBComponentWithRestorableUIState>)self.component restoreUIState:restoredUIState];
    }
}

- (void)prepareForReuseAndSendToReusePool:(BOOL)sendToReusePool
{
    if (!self.preparedForReuse) {
        [self saveComponentUIState];
        [self.component prepareViewForReuse];
        self.preparedForReuse = YES;
    }
    
    if (sendToReusePool) {
        [self.delegate sendComponentWrapperToReusePool:self];
    }
}

@end

NS_ASSUME_NONNULL_END
