#import "HUBComponentWrapper.h"

#import "HUBComponentWithChildren.h"
#import "HUBComponentWithRestorableUIState.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBComponentUIStateManager.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapper () <HUBComponentChildDelegate>

@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;

@end

@implementation HUBComponentWrapper

- (instancetype)initWithComponent:(id<HUBComponent>)component
                            model:(id<HUBComponentModel>)model
                   UIStateManager:(HUBComponentUIStateManager *)UIStateManager
{
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _component = component;
        _componentIdentifier = [model.componentIdentifier copy];
        _UIStateManager = UIStateManager;
        _currentModel = model;
        
        if ([_component conformsToProtocol:@protocol(HUBComponentWithChildren)]) {
            ((id<HUBComponentWithChildren>)_component).childDelegate = self;
        }
    }
    
    return self;
}

#pragma mark - API

- (void)saveComponentUIState
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id currentUIState = [(id<HUBComponentWithRestorableUIState>)self.component currentUIState];
    
    if (currentUIState == nil) {
        [self.UIStateManager removeSavedUIStateForComponentModel:self.currentModel];
    } else {
        [self.UIStateManager saveUIState:currentUIState forComponentModel:self.currentModel];
    }
}

- (void)restoreComponentUIState
{
    if (![self.component conformsToProtocol:@protocol(HUBComponentWithRestorableUIState)]) {
        return;
    }
    
    id restoredUIState = [self.UIStateManager restoreUIStateForComponentModel:self.currentModel];
    
    if (restoredUIState != nil) {
        [(id<HUBComponentWithRestorableUIState>)self.component restoreUIState:restoredUIState];
    }
}

#pragma mark - HUBComponentChildDelegate

- (nullable id<HUBComponent>)component:(id<HUBComponentWithChildren>)component createChildComponentAtIndex:(NSUInteger)childIndex
{
    NSArray * const childComponentModels = self.currentModel.childComponentModels;
    
    if (childIndex >= childComponentModels.count) {
        return nil;
    }
    
    id<HUBComponentModel> const childModel = childComponentModels[childIndex];
    return [self.delegate componentWrapper:self createChildComponentWithModel:childModel];
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

@end

NS_ASSUME_NONNULL_END
