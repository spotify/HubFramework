#import "HUBSerializable.h"
#import "HUBComponentCategories.h"

@class HUBIdentifier;
@protocol HUBComponentImageData;
@protocol HUBComponentModel;
@protocol HUBComponentTarget;
@protocol HUBViewModel;
@protocol HUBIcon;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a model object that is used for a Component in the Hub Framework
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create implementations of it
 *  for you based on the data supplied to a `HUBComponentModelBuilder` or through JSON data.
 *
 *  See also `HUBComponent` that acts as the controller for a view that renders the data from a `HUBComponentModel`.
 *
 *  What pieces of data each individual component supports is up to them. It's also up to the components themselves
 *  to control their own rendering of the data contained in a model like this. However, it's always safe to assign any
 *  of the properties in this model, regardless of component implementation. Components that don't support a certain
 *  piece of data (like `subtitle` or `descriptionText` for example), will simply choose to ignore those properties.
 *
 *  This protocol defines an immutable component model, for its mutable counterpart; see `HUBComponentModelBuilder`.
 */
@protocol HUBComponentModel <HUBSerializable>

#pragma mark - Identifier & index

/**
 *  The identifier of this model
 *
 *  Used internally to identify this instance, but may also be used by logging or during
 *  debugging to distinguish this set of data from others.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 *  The index of the model, either within its parent or within the root list
 *
 *  Components that use nested models can use this property to determine which child to map a certain model to
 */
@property (nonatomic, readonly) NSUInteger index;

#pragma mark - Component

/**
 *  The identifier of the component that this model should be rendered using
 *
 *  The component identifier's namespace should match the namespace of a registered `HUBComponentFactory`.
 *  If no component can be resolved for this identifier, a fallback one will be used.
 */
@property (nonatomic, copy, readonly) HUBIdentifier *componentIdentifier;

/**
 *  The category of the component that this model should be rendered using
 *
 *  The Hub Framework uses the value of this property to create a fallback component in case no component could be
 *  created by any registered `HUBComponentFactory` for the model's `componentIdentifier`
 */
@property (nonatomic, copy, readonly) HUBComponentCategory *componentCategory;

#pragma mark - Text

/**
 *  Any title that the component should render
 *
 *  A title is a component's most prominent text content. It will usually be rendered using a slightly bigger font.
 */
@property (nonatomic, copy, nullable, readonly) NSString *title;

/**
 *  Any subtitle that the component should render
 *
 *  A subtitle is a component's second most prominent text content. It will usually act as a companion to the `title`.
 */
@property (nonatomic, copy, nullable, readonly) NSString *subtitle;

/**
 *  Any accessory title that the component should render
 *
 *  An accessory title is a supplementary piece of text that is usually used to render metadata or some form of accessory
 *  information with less prominance.
 */
@property (nonatomic, copy, nullable, readonly) NSString *accessoryTitle;

/**
 *  Any description text that the component should render
 *
 *  A description text is a longer body of text that usually provides more contextual information about the content that the
 *  component is rendering.
 */
@property (nonatomic, copy, nullable, readonly) NSString *descriptionText;

#pragma mark - Images

/**
 *  Image data for any "main" image that the component should render
 *
 *  A main image is normally the image that has the most visual prominence in the component, but each component is free to
 *  determine how this data is used.
 *
 *  See `HUBComponentImageData` for more information.
 */
@property (nonatomic, strong, nullable, readonly) id<HUBComponentImageData> mainImageData;

/**
 *  Image data for any background image that the component should render
 *
 *  A background image is normally renderered behind the rest of the component's content, but each component is free to
 *  determine how this data is used.
 *
 *  See `HUBComponentImageData` for more information.
 */
@property (nonatomic, strong, nullable, readonly) id<HUBComponentImageData> backgroundImageData;

/**
 *  Dictionary containing image data objects that describe how to render any custom images for the component
 *
 *  The keys in this dictionary specify the identifiers of the images, that the component can use to determine their layout.
 *
 *  For default images, see `mainImagedata` and `backgroundImageData`.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id<HUBComponentImageData>> *customImageData;

/**
 *  Any icon that the component should render
 *
 *  Use the icon object to retrieve an image for a given size. See `HUBIcon` for more information.
 */
@property (nonatomic, strong, nullable, readonly) id<HUBIcon> icon;

#pragma mark - Target

/**
 *  Any target of a user interaction with the component
 *
 *  A component's target contains information about what should happen when a user interacts with it. For example, any URI
 *  that should be opened, or any initial view model that should be used for the target view. See `HUBComponentTarget` for
 *  more information.
 */
@property (nonatomic, strong, nullable, readonly) id<HUBComponentTarget> target;

#pragma mark - Metadata & Customization

/**
 *  Any application-specific metadata that should be associated with the component
 *
 *  Use this for any metadata that is not consumed by the component itself, such as model metadata (music metadata for a music player,
 *  photo metadata for a photo editor, for example). For component customization options; use the `customData` dictionary instead.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject *> *metadata;

/**
 *  Any data that should be logged alongside interactions or impressions for the component
 *
 *  The format of this dictionary is completely free form, but since at some point it will end up being serialized, make sure that
 *  it only contains serializable values.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject *> *loggingData;

/**
 *  Any custom data that the component should use
 *
 *  If a component has some specific customizability options they can be specified here. See the documentation for each `HUBComponent`
 *  implementation for what keys are supported, and for what options. For other types of metadata, such as application-specific model
 *  data (music metadata for a music player, photo metadata for a photo editor, for example), that don't relate to the component itself,
 *  use the `metadata` dictionary.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject *> *customData;

#pragma mark - Child models

/**
 *  Any component models that are children of this model
 *
 *  The Hub Framework supports nested components, but it’s up to each `HUBComponent` implementation to decide what to do
 *  with them. For example, when creating a carousel-like component, the children of that component might be the items that
 *  the carousel contains.
 */
@property (nonatomic, strong, nullable, readonly) NSArray<id<HUBComponentModel>> *childComponentModels;

/**
 *  Return a child component model for a given index, or `nil` if an invalid index was supplied
 *
 *  @param childIndex The index to return a child component model for
 *
 *  This method is a convenience API for accessing child component models directly using the `childComponentModels` property, since
 *  it's fine to call this method with an index that is not known to be valid (since it will fail gracefully and return `nil`).
 */
- (nullable id<HUBComponentModel>)childComponentModelAtIndex:(NSUInteger)childIndex;

@end

NS_ASSUME_NONNULL_END
