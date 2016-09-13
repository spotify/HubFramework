#import "HUBActionHandlerMock.h"

#import "HUBActionContext.h"

@interface HUBActionHandlerMock ()

@property (nonatomic, strong, readonly) NSMutableArray<id<HUBActionContext>> *mutableContexts;

@end

@implementation HUBActionHandlerMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableContexts = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSArray<id<HUBActionContext>> *)contexts
{
    return [self.mutableContexts copy];
}

#pragma mark - HUBActionHandler

- (BOOL)handleActionWithContext:(id<HUBActionContext>)context
{
    if (self.block == nil) {
        return NO;
    }
    
    [self.mutableContexts addObject:context];
    
    return self.block(context);
}

@end
