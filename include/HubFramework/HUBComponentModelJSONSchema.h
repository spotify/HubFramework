#import <Foundation/Foundation.h>

@protocol HUBJSONStringPath;
@protocol HUBJSONDictionaryPath;
@protocol HUBJSONURLPath;
@protocol HUBJSONDatePath;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a JSON schema used to extract data for a `HUBComponentModel`
 *
 *  You don't conform to this protocol yourself, instead an object conforming to it will come attached
 *  when you create a `HUBJSONSchema` (see its documentation for more info). The implementation of this
 *  protocol will come setup according to the default Hub Framework JSON schema, but you're free to change
 *  & extend it to fit any schema that you expect your JSON data to conform to.
 *
 *  A schema is defined as a collection of paths, that each describe the operations required to extract
 *  a certain piece of data from a JSON structure. For a more in-depth description on how paths work, see the
 *  documentation for `HUBJSONPath` and `HUBMutableJSONPath`. For more information about the properties that
 *  the data extractd using this schema will be used for, see `HUBComponentModel`.
 *
 *  To change a path - either create a `mutableCopy` of it, change it, and re-assign it back to its property,
 *  or create a new path from scratch using `HUBJSONSchema`.
 *
 *  All paths in this schema are relative to a JSON dictionary defining component model data.
 */
@protocol HUBComponentModelJSONSchema <NSObject>

/// The path to follow to extract a component model identifier. Maps to `identifier.
@property (nonatomic, strong) id<HUBJSONStringPath> identifierPath;

/// The path to follow to extract a component identifier. Maps to `componentIdentifier`.
@property (nonatomic, strong) id<HUBJSONStringPath> componentIdentifierPath;

/// The path to follow to extract a component category. Maps to `componentCategory`.
@property (nonatomic, strong) id<HUBJSONStringPath> componentCategoryPath;

/// The path to follow to extract a title. Maps to `title`.
@property (nonatomic, strong) id<HUBJSONStringPath> titlePath;

/// The path to follow to extract a subtitle. Maps to `subtitle`.
@property (nonatomic, strong) id<HUBJSONStringPath> subtitlePath;

/// The path to follow to extract an accessory title. Maps to `accessoryTitle`.
@property (nonatomic, strong) id<HUBJSONStringPath> accessoryTitlePath;

/// The path to follow to extract a description text. Maps to `descriptionText`.
@property (nonatomic, strong) id<HUBJSONStringPath> descriptionTextPath;

/**
 *  The path to follow to extract image data for a component's main image. Maps to `mainImageData`.
 *
 *  The dictionary extracted by following this path will then be parsed using `HUBComponentImageDataJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> mainImageDataDictionaryPath;

/**
 *  The path to follow to extract image data for a component's background image. Maps to `backgroundImageData`.
 *
 *  The dictionary extracted by following this path will then be parsed using `HUBComponentImageDataJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> backgroundImageDataDictionaryPath;

/**
 *  The path to follow to extract a dictionary of image data for a component's custom images. Maps to `customImageData`.
 *
 *  The dictionaries contained in the dictionary extracted by following this path will then be parsed using
 *  `HUBComponentImageDataJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> customImageDataDictionaryPath;

/// The path to follow to extract an icon identifier for the component. Maps to `iconIdentifier`.
@property (nonatomic, strong) id<HUBJSONStringPath> iconIdentifierPath;

/**
 *  The path to follow to extract a dictionary to use to construct a target for the component. Maps to `target`.
 *
 *  The dictionary extracted by following this path will then be parsed using `HUBComponentTargetJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> targetDictionaryPath;

/// The path to follow to extract any metadata for the component model. Maps to `metadata`.
@property (nonatomic, strong) id<HUBJSONDictionaryPath> metadataPath;

/// The path to follow to extract any logging data for a component. Maps to `loggingData`.
@property (nonatomic, strong) id<HUBJSONDictionaryPath> loggingDataPath;

/// The path to follow to extract any custom data for a component. Maps to `customData`.
@property (nonatomic, strong) id<HUBJSONDictionaryPath> customDataPath;

/**
 *  The path to follow to extract dictionaries to create child component models from. Maps to `childComponentModels`.
 *
 *  The dictionaries extracted by following this path will then be parsed recursively by this schema.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> childComponentModelDictionariesPath;

/// Create a copy of this schema, with the same paths
- (id<HUBComponentModelJSONSchema>)copy;

@end

NS_ASSUME_NONNULL_END
