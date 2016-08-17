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

@property (nonatomic, strong, readonly) id<HUBComponent> component;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, weak) HUBComponentWrapperImplementation *parentComponentWrapper;
@property (nonatomic, assign) BOOL preparedForReuse;

@end

@implementation HUBComponentWrapperImplementation

@synthesize identifier = _identifier;

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
        _component = component;
        _UIStateManager = UIStateManager;
        _model = model;
        _delegate = delegate;
        _parentComponentWrapper = parentComponentWrapper;

        if ([_component conformsToProtocol:@protocol(HUBComponentWithChildren)]) {
            ((id<HUBComponentWithChildren>)_component).childDelegate = self;
        }

        UIView * const componentView = self.view;
        if ([_component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
            HUBComponentResizeObservingView * const resizeObservingView = [[HUBComponentResizeObservingView alloc] initWithFrame:componentView.bounds];
            resizeObservingView.delegate = self;
            [componentView addSubview:resizeObservingView];
        }
        
        HUBComponentLoadViewIfNeeded(_component);
        const CGSize containerViewSize = [delegate containerViewSizeForComponentWrapper:self];
        [_component configureViewWithModel:_model containerViewSize:containerViewSize];
    }
    
    return self;
}

#pragma mark - API

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

- (void)viewWillAppear
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
        return;
    }
    
    [(id<HUBComponentViewObserver>)self.component viewWillAppear];
}

- (void)contentOffsetDidChange:(CGPoint)contentOffset
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentContentOffsetObserver)]) {
        return;
    }
    
    [(id<HUBComponentContentOffsetObserver>)self.component updateViewForChangedContentOffset:contentOffset];
}

#pragma mark - Property overrides

- (void)setModel:(id<HUBComponentModel>)model
{
    if (_model == model && !self.preparedForReuse) {
        return;
    }
    
    _model = model;
    
    if (!self.preparedForReuse) {
        [self prepareForReuseAndSendToReusePool:NO];
    }
    const CGSize containerViewSize = [self.delegate containerViewSizeForComponentWrapper:self];
    [self.component configureViewWithModel:model containerViewSize:containerViewSize];
    [self restoreComponentUIState];
    
    self.preparedForReuse = NO;
}

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
    return !self.parentComponentWrapper;
}

#pragma mark - HUBComponentWrapper

- (UIView *)view
{
    return HUBComponentLoadViewIfNeeded(self.component);
}

- (CGSize)preferredViewSizeForContainerViewSize:(CGSize)containerViewSize
{
    return [self.component preferredViewSizeForDisplayingModel:self.model containerViewSize:containerViewSize];
}

- (void)prepareForReuse
{
    [self prepareForReuseAndSendToReusePool:YES];
}

#pragma mark - HUBComponentChildDelegate

- (id<HUBComponentWrapper>)component:(id<HUBComponentWithChildren>)component childComponentForModel:(id<HUBComponentModel>)childComponentModel
{
    return (id<HUBComponentWrapper>)[self.delegate componentWrapper:self childComponentForModel:childComponentModel];
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

- (void)restoreComponentUIState
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id restoredUIState = [self.UIStateManager restoreUIStateForComponentModel:self.model];
    
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
