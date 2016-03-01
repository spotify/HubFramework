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
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifier = [NSUUID UUID];
    _component = component;
    _component.delegate = self;
    _componentIdentifier = [componentIdentifier copy];
    
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

@end

NS_ASSUME_NONNULL_END
