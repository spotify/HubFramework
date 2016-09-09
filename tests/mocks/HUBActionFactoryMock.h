#import "HUBActionFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked action factory, for use in unit tests only
@interface HUBActionFactoryMock : NSObject <HUBActionFactory>

/// The actions that this factory will serve, indexed by name
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBAction>> *actions;

/**
 *  Initialize an instance of this class
 *
 *  @param actions The actions that the factory will serve
 */
- (instancetype)initWithActions:(nullable NSDictionary<NSString *, id<HUBAction>> *)actions HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
