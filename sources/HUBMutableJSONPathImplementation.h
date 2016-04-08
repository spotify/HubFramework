#import "HUBMutableJSONPath.h"
#import "HUBHeaderMacros.h"

@class HUBJSONParsingOperation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBMutableJSONPath` API
@interface HUBMutableJSONPathImplementation : NSObject <HUBMutableJSONPath>

/**
 *  Convenience class constructor to create an empty mutable path
 */
+ (instancetype)path;

/**
 *  Initialize an instance of this class with an array of parsing operations
 *
 *  @param parsingOperations The parsing operations that this path will consist of
 */
- (instancetype)initWithParsingOperations:(NSArray<HUBJSONParsingOperation *> *)parsingOperations HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
