#import "HUBJSONPath.h"

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
- (instancetype)initWithParsingOperations:(NSArray<HUBJSONParsingOperation *> *)parsingOperations NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
