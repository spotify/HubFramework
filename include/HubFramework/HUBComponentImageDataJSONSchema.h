#import <Foundation/Foundation.h>

#import "HUBJSONPath.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a JSON schema for `HUBComponentImageData`
 *
 *  You don't conform to this protocol yourself, instead an object matching the default Hub Framework schema will
 *  come attached to a `HUBJSONSchema`. You are free to customize a schema in whatever way you want, but you must
 *  do so before registering it with the `HUBJSONSchemaRegistry`.
 *
 *  The Hub Framework uses a path-based approach to JSON parsing, that enables you to describe how to retrieve data
 *  from a JSON structure using paths - sequences of operations that each perform a JSON parsing task, such as going
 *  to a key in a dictionary, or iterating over an array. For more information about how to construct paths, see the
 *  documentation for `HUBJSONPath` and `HUBMutableJSONPath`.
 *
 *  All paths in this schema are relative to a dictionary containing image data for a component.
 */
@protocol HUBComponentImageDataJSONSchema <NSObject>

/**
 *  The path that points to a string that can be mapped to a `HUBComponentImageStyle`, according to `styleStringMap`
 *  Maps to `style`, by using `styleStringMap`.
 */
@property (nonatomic, strong) id<HUBJSONStringPath> styleStringPath;

/// The map to use to map a string extracted using `styleStringPath` into a `HUBComponentImageStyle` value
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *styleStringMap;

/// The path that points to a HTTP image URL for the image that the data is for. Maps to `URL`.
@property (nonatomic, strong) id<HUBJSONURLPath> URLPath;

/// The path that points to a placeholder icon identifier. Maps to `placeholderIconIdentifier`.
@property (nonatomic, strong) id<HUBJSONStringPath> placeholderIconIdentifierPath;

/// Create a copy of this schema, with the same paths
- (id<HUBComponentImageDataJSONSchema>)copy;

@end

NS_ASSUME_NONNULL_END
