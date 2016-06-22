#import <Foundation/Foundation.h>

@protocol HUBJSONSchema;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API for adding JSON data to a Hub Framework model builder
 *
 *  Builders that support JSON data will conform to this protocol. Most builders only support Dictionary-based
 *  JSON, except for `HUBViewModelBuilder` that supports Array-based JSON for defining an array of body
 *  component models.
 */
@protocol HUBJSONCompatibleBuilder <NSObject>

/**
 *  Add binary JSON data to the builder
 *
 *  @param JSONData The JSON data to add
 *
 *  The builder will use its feature's `HUBJSONSchema` to parse the data that was added, and return any error that
 *  occured while doing so, or nil if the operation was completed successfully.
 */
- (nullable NSError *)addJSONData:(NSData *)JSONData;

/**
 *  Add a JSON dictionary to this builder
 *
 *  @param dictionary The JSON dictionary to extract content from
 *
 *  The content that was extracted from the supplied dictionary will replace any previously defined content.
 */
- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

NS_ASSUME_NONNULL_END

