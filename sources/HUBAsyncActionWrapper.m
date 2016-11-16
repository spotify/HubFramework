#import "HUBAsyncActionWrapper.h"
#import "HUBAsyncAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBAsyncActionWrapper () <HUBAsyncActionDelegate>

@property (nonatomic, strong, readonly) id<HUBAsyncAction> action;
@property (nonatomic, strong, readonly) id<HUBActionContext> context;

@end

@implementation HUBAsyncActionWrapper

#pragma mark - Initializer

- (instancetype)initWithAction:(id<HUBAsyncAction>)action context:(id<HUBActionContext>)context
{
    NSParameterAssert(action != nil);
    NSParameterAssert(context != nil);
    
    self = [super init];
    
    if (self) {
        _action = action;
        _context = context;
        
        _action.delegate = self;
    }
    
    return self;
}

#pragma mark - API

- (BOOL)perform
{
    return [self.action performWithContext:self.context];
}

#pragma mark - HUBAsyncActionDelegate

- (void)actionDidFinish:(id<HUBAsyncAction>)action
        chainToActionWithIdentifier:(nullable HUBIdentifier *)nextActionIdentifier
             customData:(nullable NSDictionary<NSString *, id> *)nextActionCustomData
{
    [self.delegate actionDidFinish:self
                       withContext:self.context
       chainToActionWithIdentifier:nextActionIdentifier
                        customData:nextActionCustomData];
}

@end

NS_ASSUME_NONNULL_END
