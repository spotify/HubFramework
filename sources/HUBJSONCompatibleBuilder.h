#import <Foundation/Foundation.h>

@protocol HUBJSONSchema;

/// Protocol that builder implementations within the Hub Framework that support JSON data conform to
@protocol HUBJSONCompatibleBuilder <NSObject>

/**
 *  Add data from a JSON dictionary to this builder
 *
 *  @param dictionary The JSON dictionary to extract data from
 *
 *  Any data already contained in the builder will be overriden by the data from the JSON dictionary
 */
- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

