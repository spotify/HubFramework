#import "HUBComponentImageDataBuilder.h"

@protocol HUBComponentImageDataJSONSchema;
@class HUBComponentImageDataImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentImageDataBuilder` API
@interface HUBComponentImageDataBuilderImplementation : NSObject <HUBComponentImageDataBuilder>

/**
 *  Add data from a JSON dictionary containing image data to this builder
 *
 *  @param dictionary The JSON dictionary to retrieve data from
 *  @param schema The JSON schema to use to extract the data from the dictionary
 *
 *  Any data already contained in this builder will be overriden by the data from the JSON dictionary
 */
- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
                      usingSchema:(id<HUBComponentImageDataJSONSchema>)schema;

/**
 *  Build an instance of `HUBComponentImageDataImplementation` from the data contained in this builder
 *
 *  If the builder has neither an `URL` or `iconIdentifier` associated with it, nil will be returned.
 */
- (nullable HUBComponentImageDataImplementation *)build;

@end

NS_ASSUME_NONNULL_END
