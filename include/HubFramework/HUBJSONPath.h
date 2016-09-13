#import <Foundation/Foundation.h>

@protocol HUBMutableJSONPath;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HUBDictionaryPath

/**
 *  Protocol defining the basic API of an object describing a path to a piece of data within a JSON structure
 *
 *  The Hub Framework uses a path-based approach to JSON parsing, that enables the API user to describe how
 *  to retrieve data from a JSON structure using paths - sequences of operations that each perform a JSON parsing
 *  task, such as going to a key in a dictionary, or iterating over an array.
 *
 *  You normally don't have to interact with the APIs defined in this file yourself. Instead, the Hub Framework
 *  uses them to retrieve data internally. You might want to construct paths yourself, though, and for that you
 *  use the mutable version of this API; `HUBMutableJSONPath`.
 */
@protocol HUBJSONPath <NSObject>

/**
 *  Return an array of values by following this path in a JSON dictionary
 *
 *  @param dictionary The JSON dictionary to apply the path on
 *
 *  @return An array of type-checked values, depending on what type that the path is associated with
 */
- (NSArray<NSObject *> *)valuesFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

/**
 *  Return a mutable copy of this path, that can be used to extend it with additional operations
 */
- (id<HUBMutableJSONPath>)mutableCopy;

@end

#pragma mark - HUBJSONBoolPath

/**
 *  Protocol defining the API of a JSON path that points to a BOOL value
 *
 *  See `HUBJSONPath` and `HUBMutableJSONPath` for more information on how JSON paths work.
 */
@protocol HUBJSONBoolPath <HUBJSONPath>

/**
 *  Return a BOOL value by following this path in a JSON dictionary
 *
 *  @param dictionary The JSON dictionary to apply the path on
 *
 *  @return A BOOL found by following the path, or `NO` as the default in case an operation in the path failed,
 *  or if the found value couldn't be converted into a BOOL.
 */
- (BOOL)boolFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

#pragma mark - HUBJSONIntegerPath

/**
 *  Protocol defining the API of a JSON path that points to an NSInteger value
 *
 *  See `HUBJSONPath` and `HUBMutableJSONPath` for more information on how JSON paths work.
 */
@protocol HUBJSONIntegerPath <HUBJSONPath>

/**
 *  Return an `NSInteger` value by following this path in a JSON dictionary
 *
 *  @param dictionary The JSON dictionary to apply the path on
 *
 *  @return An NSInteger value found by following the path, or `0` as the default in case an operation in the path
 *  failed, or if the found value couldn't be converted into an `NSInteger`.
 */
- (NSInteger)integerFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

#pragma mark - HUBJSONStringPath

/**
 *  Protocol defining the API of a JSON path that points to an `NSString` value
 *
 *  See `HUBJSONPath` and `HUBMutableJSONPath` for more information on how JSON paths work.
 */
@protocol HUBJSONStringPath <HUBJSONPath>

/**
 *  Return an `NSString` value by following this path in a JSON dictionary
 *
 *  @param dictionary The JSON dictionary to apply the path on
 *
 *  @return An `NSString` value found by following the path, or `nil` as the default in case an operation in the path
 *  failed, or if the found value wasn't an `NSString` instance.
 */
- (nullable NSString *)stringFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

#pragma mark - HUBJSONURLPath

/**
 *  Protocol defining the API of a JSON path that points to an `NSURL` value
 *
 *  See `HUBJSONPath` and `HUBMutableJSONPath` for more information on how JSON paths work.
 */
@protocol HUBJSONURLPath <HUBJSONPath>

/**
 *  Return an `NSURL` value by following this path in a JSON dictionary
 *
 *  @param dictionary The JSON dictionary to apply the path on
 *
 *  @return An `NSURL` instance parsed from an `NSString` value found by following the path, or `nil` as the default in
 *  case an operation in the path failed, or if the found value wasn't an `NSString` or couldn't be parsed into an `NSURL`.
 */
- (nullable NSURL *)URLFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

#pragma mark - HUBJSONDictionaryPath

/**
 *  Protocol defining the API for a JSON path that points to an `NSDictionary` value
 *
 *  See `HUBJSONPath` and `HUBMutableJSONPath` for more information on how JSON paths work.
 */
@protocol HUBJSONDictionaryPath <HUBJSONPath>

/**
 *  Return an `NSDictionary` value by following this path in a JSON dictionary
 *
 *  @param dictionary The JSON dictionary to apply the path on
 *
 *  @return An `NSDictionary` value found by following the path, or `nil` as the default in case an operation in the path
 *  failed, or if the found value wasn't an `NSDictionary` instance.
 */
- (nullable NSDictionary<NSString *, NSObject *> *)dictionaryFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

NS_ASSUME_NONNULL_END
