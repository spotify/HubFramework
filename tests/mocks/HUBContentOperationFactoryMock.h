#import "HUBContentOperationFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content operation factory, for use in tests only
@interface HUBContentOperationFactoryMock : NSObject <HUBContentOperationFactory>

/**
 *  Initialize an instance of this class with an array of content operations
 *
 *  @param contentOperations The content operations that this factory is always returning
 */
- (instancetype)initWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
