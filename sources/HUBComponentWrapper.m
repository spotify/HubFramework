#import "HUBComponentWrapper.h"

#import "HUBComponentWithChildren.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentWrapper () <HUBComponentChildEventHandler>

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
            ((id<HUBComponentWithChildren>)_component).childEventHandler = self;
        }
    }
    
    return self;
}

#pragma mark - HUBComponentDelegate

- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self componentWillDisplayChildAtIndex:childIndex];
}

- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex
{
    if (self.component != component) {
        return;
    }
    
    [self.delegate componentWrapper:self childComponentSelectedAtIndex:childIndex];
}

@end

NS_ASSUME_NONNULL_END
