#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Class representing a JSON parsing operation that is part of a path
@interface HUBJSONParsingOperation : NSObject

/**
 *  Initialize an instance of this class with a block that contains the parsing operation to perform
 *
 *  @param block The block that contains the logic of the parsing operation
 */
- (instancetype)initWithBlock:(nullable NSArray<NSObject *> *(^)(NSObject *))block NS_DESIGNATED_INITIALIZER;

/**
 *  Return an array of parsed values for performing this operation with a certain input
 *
 *  @param input The input to perform the operation with
 *
 *  @return An array of output values that are the product of performing the operation, or nil if the operation
 *  couldn't be successfully performed.
 */
- (nullable NSArray<NSObject *> *)parsedValuesForInput:(NSObject *)input;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
