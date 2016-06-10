#import <Foundation/Foundation.h>

@protocol HUBViewModelJSONSchema;
@protocol HUBComponentModelJSONSchema;
@protocol HUBComponentImageDataJSONSchema;
@protocol HUBMutableJSONPath;
@protocol HUBViewModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of an object describing a JSON schema for use in the Hub Framework
 *
 *  You don't conform to this protocol yourself, instead you retrieve an instance conforming to it from
 *  the `HUBJSONSchemaRegistry` used by the application's `HUBManager`. A `HUBJSONSchema` comes setup
 *  according to the default Hub Framework JSON schema, but you're free to change & extend it to fit
 *  any schema that you expect your JSON data to conform to.
 *
 *  A `HUBJSONSchema` consists of several sub-schemas, one for each model. The schemas may be individually
 *  customized. See their respective documentation for more info on how to customize them.
 *
 *  The Hub Framework uses a path-based approach to JSON parsing, that enables the API user to describe how to
 *  retrieve data from a JSON structure using paths - sequences of operations that each perform a JSON parsing task,
 *  such as going to a key in a dictionary, or iterating over an array. To customize a path, you can either change
 *  it directly, or replace it with a new one created from this schema's  `-createNewPath` method.
 *
 *  For a more in-depth description on how paths work, see the documentation for `HUBJSONPath` and `HUBMutableJSONPath`.
 */
@protocol HUBJSONSchema <NSObject>

/// The schema used to retrieve data for `HUBViewModel` objects
@property (nonatomic, strong, readonly) id<HUBViewModelJSONSchema> viewModelSchema;

/// The schema used to retrieve data for `HUBComponentModel` objects
@property (nonatomic, strong, readonly) id<HUBComponentModelJSONSchema> componentModelSchema;

/// The schema used to retrieve data for `HUBComponentImageData` objects
@property (nonatomic, strong, readonly) id<HUBComponentImageDataJSONSchema> componentImageDataSchema;

/**
 *  Create a new, blank, mutable JSON path that can be used to describe how to retrieve data for a certain property
 *
 *  See `HUBMutableJSONPath` for more information
 */
- (id<HUBMutableJSONPath>)createNewPath;

/**
 *  Perform a deep copy of this schema, returning a new instance that has the exact same paths as this one
 */
- (id<HUBJSONSchema>)copy;

/**
 *  Return a view model created by extracting data from a given JSON dictionary, using this schema
 *
 *  @param dictionary The JSON dictionary to extract data from
 *  @param featureIdentifier The feature identifier that the returned view model is for
 *
 *  In production code, you normally don't have to use this API, since the Hub Framework will take care of building
 *  view models from both JSON and local content operation code for you. However, this API is very useful in tests,
 *  when you want to assert that any custom schema that you're using acts the way you expect it to.
 */
- (id<HUBViewModel>)viewModelFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
                              featureIdentifier:(NSString *)featureIdentifier;

@end

NS_ASSUME_NONNULL_END
