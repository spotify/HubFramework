#import "HUBComponentWrapper.h"

#import "HUBComponent.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapper () <HUBComponentDelegate>

@end

@implementation HUBComponentWrapper

- (instancetype)initWithComponent:(id<HUBComponent>)component componentIdentifier:(HUBComponentIdentifier *)componentIdentifier
{
    self = [super init];
    
    if (self) {
        _identifier = [NSUUID UUID];
        _component = component;
        _component.delegate = self;
        _componentIdentifier = [componentIdentifier copy];
    }
    
    return self;
}

#pragma mark - HUBComponentDelegate

- (void)component:(id<HUBComponent>)component willDisplayChildAtIndex:(NSUInteger)childIndex
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self componentWillDisplayChildAtIndex:childIndex];
}

- (void)component:(id<HUBComponent>)component childSelectedAtIndex:(NSUInteger)childIndex
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self childComponentSelectedAtIndex:childIndex];
}

@end

NS_ASSUME_NONNULL_END
