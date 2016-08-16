#import <UIKit/UIKit.h>

#import "HUBJSONCompatibleBuilder.h"
#import "HUBComponentCategories.h"

@class HUBComponentIdentifier;
@protocol HUBComponentImageDataBuilder;
@protocol HUBViewModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API for a builder that builds component model objects
 *
 *  This builder acts like a mutable model counterpart for `HUBComponentModel`, with the key
 *  difference that they are not related by inheritance.
 *
 *  All properties are briefly documented as part of this protocol, but for more extensive
 *  documentation and use case examples, see the full documentation in the `HUBComponentModel`
 *  protocol definition.
 */
@protocol HUBComponentModelBuilder <HUBJSONCompatibleBuilder>

#pragma mark - Identifier & index

/// The identifier of the model that this builder is for
@property (nonatomic, copy, readonly) NSString *modelIdentifier;

/// The index that the component would prefer to be placed at. Can be used to move components locally.
@property (nonatomic, copy, nullable) NSNumber *preferredIndex;

#pragma mark - Component

/**
 *  The namespace of the component that the model should be rendered using
 *
 *  The default value of this property is the `defaultComponentNamespace` declared by the application's implementation
 *  of `HUBComponentFallbackHandler`. If overriden, it should match the namespace of a registered `HUBComponentFactory`,
 *  which will be asked to create a component for the model's `componentName`.
 *
 *  In case no `HUBComponentFactory` could be resolved for the namespace, the Hub Framework will use its fallback handler
 *  to create a fallback component using the model's `componentCategory`.
 */
@property (nonatomic, copy) NSString *componentNamespace;

/**
 *  The name of the component that the model should be rendered using
 *
 *  The default value of this property is the `defaultComponentName` declared by the application's implementation
 *  of `HUBComponentFallbackHandler`. It will be sent to the `HUBComponentFactory` resolved for `componentNamespace`,
 *  which will be asked to create a component for the model.
 */
@property (nonatomic, copy) NSString *componentName;

/**
 *  The category of the component that the model should be rendered using
 *
 *  The default value of this property is the `defaultComponentCategory` declared by the application's implementation
 *  of `HUBComponentFallbackHandler`. It is sent to the fallback handler in case no component could be created for the
 *  model's `componentNamespace`/`componentName` combo - so that a fallback component may be created with similar
 *  visuals as the originally intended component.
 */
@property (nonatomic, copy) HUBComponentCategory *componentCategory;

#pragma mark - Text

/// Any title that the component should render
@property (nonatomic, copy, nullable) NSString *title;

/// Any subtitle that the component should render
@property (nonatomic, copy, nullable) NSString *subtitle;

/// Any accessory title that the component should render
@property (nonatomic, copy, nullable) NSString *accessoryTitle;

/// Any longer describing text that the component should render
@property (nonatomic, copy, nullable) NSString *descriptionText;

#pragma mark - Images

/// A builder that can be used to construct data that describes how to render the component's "main" image
@property (nonatomic, strong, readonly) id<HUBComponentImageDataBuilder> mainImageDataBuilder;

/// Any URL for the component's "main" image. This is an alias for `mainImageDataBuilder.URL`.
@property (nonatomic, copy, nullable) NSURL *mainImageURL;

/// Any local component "main" image. This is an alias for `mainImageDataBuilder.localImage`.
@property (nonatomic, strong, nullable) UIImage *mainImage;

/// A builder that can be used to construct data that describes how to render the component's background image
@property (nonatomic, strong, readonly) id<HUBComponentImageDataBuilder> backgroundImageDataBuilder;

/// Any URL for the component's background image. This is an alias for `backgroundImageDataBuilder.URL`.
@property (nonatomic, copy, nullable) NSURL *backgroundImageURL;

/// Any local component background image. This is an alias for `backgroundImageDataBuilder.localImage`.
@property (nonatomic, strong, nullable) UIImage *backgroundImage;

/// Any identifier of any icon that should be used with the component
@property (nonatomic, copy, nullable) NSString *iconIdentifier;

#pragma mark - Target

/// Any URL that is the target of a user interaction with the component
@property (nonatomic, copy, nullable) NSURL *targetURL;

/// A builder that can be used to construct a pre-computed view model for a view that is the target of `targetURL`
@property (nonatomic, strong, readonly) id<HUBViewModelBuilder> targetInitialViewModelBuilder;

#pragma mark - Metadata

/// Any application-specific model metadata that should be associated with the component
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *metadata;

/// Any data that should be logged alongside interactions or impressions for the component
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *loggingData;

/// Any custom data that the component should use
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *customData;

#pragma mark - Custom image data builders

/**
 *  Return whether this builder contains a builder for custom image data for a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForCustomImageDataWithIdentifier:(NSString *)identifier;

/**
 *  Get or create a builder for data for a custom image with a certain identifier
 *
 *  @param identifier The identifier of the image
 *
 *  @return If a builder already exists for the supplied identifier, then it's returned. Otherwise a new builder is
 *  created, which can be used to build an image data model. Since this method lazily creates a builder in case one
 *  doesn't already exist, use the `-builderExistsForImageDataWithIdentifier:` API instead if you simply wish to
 *  check for the existance of a builder. See `HUBComponentImageDataBuilder` for more information.
 */
- (id<HUBComponentImageDataBuilder>)builderForCustomImageDataWithIdentifier:(NSString *)identifier;

#pragma mark - Child component model builders

/**
 *  Return all current child component model builders
 *
 *  @return All the existing child component model builders, in the order that they were created. Note that
 *  any `preferredIndex` set by the component model builders hasn't been resolved at this point, so those
 *  are not taken into account.
 */
- (NSArray<id<HUBComponentModelBuilder>> *)allChildComponentModelBuilders;

/**
 *  Return whether this builder contains a builder for a child component model builder with a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForChildComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Get or create a builder for a child component model with a certain identifier
 *
 *  @param identifier The identifier that the component model should have
 *
 *  @return If a builder already exists for the supplied identifier, then it's returned. Otherwise a new builder is
 *  created, which can be used to build a child component model. If a new builder is created, it will have the same
 *  `componentNamespace` and `componentName` as its parent. Since this method lazily creates a builder in case one
 *  doesn't already exist, use the `-builderExistsForChildComponentModelWithIdentifier:` API instead if you simply
 *  wish to check for the existance of a builder.
 */
- (id<HUBComponentModelBuilder>)builderForChildComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Remove a builder for a child component model with a certain identifier
 *
 *  @param identifier The identifier of the child component model builder to remove
 */
- (void)removeBuilderForChildComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Remove all builders for child component models contained within this builder
 */
- (void)removeAllChildComponentModelBuilders;

@end

NS_ASSUME_NONNULL_END
