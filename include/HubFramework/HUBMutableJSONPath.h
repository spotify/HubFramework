#import <Foundation/Foundation.h>

@protocol HUBJSONBoolPath;
@protocol HUBJSONIntegerPath;
@protocol HUBJSONStringPath;
@protocol HUBJSONURLPath;
@protocol HUBJSONDatePath;
@protocol HUBJSONDictionaryPath;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the API of a mutable JSON path, that is used to describe operations to perform to retrieve
 *  a certain piece of data from a JSON structure.
 *
 *  You use this API to customize how the Hub Framework should parse a downloaded JSON structure for a feature,
 *  by either extending an existing `HUBJSONPath` or creating a new one through `HUBJSONSchema`.
 *
 *  A path consists of a sequence of operations that each perform a JSON parsing task, such as going to a key in
 *  a dictionary, or iterating over an array. You append operations to a path by calling any of the methods listed
 *  under "Operations", and finally convert it into an immutable, destination path by calling any of the methods
 *  listed under "Destinations".
 *
 *  For example; if you wish to express the string "Sunday" from this JSON dictionary:
 *
 *  @code
 *  {
 *      "date": {
 *          "weekday": "Sunday"
 *      }
 *  }
 *  @endcode
 *
 *  You would construct a path accordingly:
 *
 *  @code
 *  [[[path goTo:@"date"] goTo:@"weekday"] stringPath];
 *  @endcode
 */
@protocol HUBMutableJSONPath <NSObject>

#pragma mark - Operations

/**
 *  Append an operation for going to a certain key in a JSON dictionary
 *
 *  @param key The key to go to
 *
 *  Use this API to traverse a JSON structure to reach the piece of data you're interested in. This operation
 *  can only be performed on dictionaries, and will fail in case it's applied on any other type.
 *
 *  @return A new mutable JSON path with the go to-operation appended. The path that you call this method on will
 *  not be modified.
 */
- (id<HUBMutableJSONPath>)goTo:(NSString *)key;

/**
 *  Append an operation for iterating through each element of a JSON array
 *
 *  Use this API to split a path into multiple sub-paths, one for each element of the target array. Any subsequent
 *  operations will be applied on all sub-paths. This operation can only be performed on arrays, and will fail in case
 *  it's applied on any other type.
 *
 *  @return A new mutable JSON path with the for each-operation appended. The path that you call this method on will
 *  not be modified.
 */
- (id<HUBMutableJSONPath>)forEach;

/**
 *  Append an operation using a custom block
 *
 *  Use this API to perform any custom JSON parsing logic on the current value of this path. When using this API you
 *  are responsible for your own type checking within the block, although the Hub Framework will always perform a
 *  final type-check at the end of the path.
 *
 *  @return A new mutable JSON path with the custom operation appended. The path that you call this method on will
 *  not be modified.
 */
- (id<HUBMutableJSONPath>)runBlock:(NSObject * _Nullable(^)(NSObject *input))block;

#pragma mark - Destinations

/**
 *  Turn this path into an immutable path that expects the destination value to be a `BOOL`
 */
- (id<HUBJSONBoolPath>)boolPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSInteger`
 */
- (id<HUBJSONIntegerPath>)integerPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSString`
 */
- (id<HUBJSONStringPath>)stringPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSString` that can be parsed
 *  into an `NSURL`.
 */
- (id<HUBJSONURLPath>)URLPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSString` that can be parsed
 *  into an `NSDate` using a default "yyyy-MM-dd" format.
 *
 *  Use `-datePathWithFormat:` to be able to use a custom date format.
 */
- (id<HUBJSONDatePath>)datePath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSString` that can be parsed
 *  into an `NSDate` using a custom date format.
 *
 *  @param dateFormat The date format to use to parse a found `NSSring` into an `NSDate`.
 */
- (id<HUBJSONDatePath>)datePathWithFormat:(NSString *)dateFormat;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSDictionary`
 */
- (id<HUBJSONDictionaryPath>)dictionaryPath;

@end

NS_ASSUME_NONNULL_END
