#import "HUBAction.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked action, for use in unit tests only
@interface HUBActionMock : NSObject <HUBAction>

/// Any block to run when the action is performed
@property (nonatomic, copy, nullable) BOOL(^block)(id<HUBActionContext>);

/**
 *  Initialize an instance of this class
 *
 *  @param block A block to run when the action is performed
 */
- (instancetype)initWithBlock:(BOOL(^_Nullable)(id<HUBActionContext>))block HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
