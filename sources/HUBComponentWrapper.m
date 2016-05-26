#import "HUBComponentWrapper.h"

#import "HUBComponentWithChildren.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapper () <HUBComponentChildDelegate>

@end

@implementation HUBComponentWrapper

- (instancetype)initWithComponent:(id<HUBComponent>)component componentIdentifier:(HUBComponentIdentifier *)componentIdentifier
{
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _component = component;
        _componentIdentifier = [componentIdentifier copy];
        
        if ([_component conformsToProtocol:@protocol(HUBComponentWithChildren)]) {
            ((id<HUBComponentWithChildren>)_component).childDelegate = self;
        }
    }
    
    return self;
}

#pragma mark - HUBComponentChildDelegate

- (nullable id<HUBComponent>)component:(id<HUBComponentWithChildren>)component createChildComponentAtIndex:(NSUInteger)childIndex
{
    NSArray * const childComponentModels = self.currentModel.childComponentModels;
    
    if (childIndex >= childComponentModels.count) {
        return nil;
    }
    
    id<HUBComponentModel> const childModel = childComponentModels[childIndex];
    id<HUBComponent> const childComponent = [self.delegate componentWrapper:self createChildComponentWithModel:childModel];
    
    UIView * const componentView = HUBComponentLoadViewIfNeeded(component);
    UIView * const childComponentView = HUBComponentLoadViewIfNeeded(childComponent);
    
    CGSize const preferredViewSize = [childComponent preferredViewSizeForDisplayingModel:childModel containerViewSize:componentView.frame.size];
    childComponentView.frame = CGRectMake(0, 0, preferredViewSize.width, preferredViewSize.height);
    
    [childComponent configureViewWithModel:childModel];
    
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

@end

NS_ASSUME_NONNULL_END
