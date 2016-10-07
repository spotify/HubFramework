#import "HUBContentOperationFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A concrete content opereation factory implementation that uses a block
 *
 *  You can use this content operation factory in case you want to implement a simple factory that
 *  doesn't need any injected dependencies or complex logic. For more advanced use cases, see the
 *  `HUBContentOperationFactory` protocol, that you can implement in a custom object.
 */
@interface HUBBlockContentOperationFactory : NSObject  <HUBContentOperationFactory>

/**
 *  Initialize an instance of this class with a block that creates content operations
 *
 *  @param block The block used to create content operations. The input parameter of the block will
 *         be the view URI that content operations should be created for. This block will be copied
 *         and called every time this factory is asked to create content operations.
 */
- (instancetype)initWithBlock:(NSArray<id<HUBContentOperation>> *(^)(NSURL *))block HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
