#import "HUBJSONPath.h"
#import "HUBHeaderMacros.h"

@class HUBJSONParsingOperation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONPath` APIs for each type
@interface HUBJSONPathImplementation : NSObject <
    HUBJSONBoolPath,
    HUBJSONIntegerPath,
    HUBJSONStringPath,
    HUBJSONURLPath,
    HUBJSONDatePath,
    HUBJSONDictionaryPath
>

/**
 *  Initialize an instance of this class with an array of parsing operations
 *
 *  @param parsingOperations The parsing operations that this path will consist of
 */
- (instancetype)initWithParsingOperations:(NSArray<HUBJSONParsingOperation *> *)parsingOperations HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
