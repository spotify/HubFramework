#import "HUBActionHandler.h"

@protocol HUBActionContext;

NS_ASSUME_NONNULL_BEGIN

/// Mocked action handler, for use in tests only
@interface HUBActionHandlerMock : NSObject <HUBActionHandler>

/// The action contexts that were sent to the handler
@property (nonatomic, strong, readonly) NSArray<id<HUBActionContext>> *contexts;

/// Any block that should be executed when this action handler is asked to handle an action
@property (nonatomic, copy, nullable) BOOL (^block)(id<HUBActionContext>);

@end

NS_ASSUME_NONNULL_END
