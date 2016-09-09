#import "HUBActionFactoryMock.h"

@implementation HUBActionFactoryMock

#pragma mark - Initializer

- (instancetype)initWithActions:(nullable NSDictionary<NSString *, id<HUBAction>> *)actions
{
    self = [super init];
    
    if (self) {
        _actions = (NSMutableDictionary *)([actions mutableCopy] ?: [NSMutableDictionary new]);
    }
    
    return self;
}

#pragma mark - HUBActionFactory

- (nullable id<HUBAction>)createActionForName:(NSString *)name
{
    return self.actions[name];
}

@end
