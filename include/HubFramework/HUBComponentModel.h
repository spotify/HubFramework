#import "HUBSerializable.h"

@class HUBComponentIdentifier;
@protocol HUBComponentImageData;
@protocol HUBComponentModel;
@protocol HUBViewModel;

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

#pragma mark - Identifiers & index

/**
 *  The identifier of this model
 *
 *  Used internally to identify this instance, but may also be used by logging or during
 *  debugging to distinguish this set of data from others.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 *  The identifier of the component that this model should be rendered using
 *
 *  The component identifier's namespace should match the namespace of a registered `HUBComponentFactory`.
 *  If no component can be resolved for this identifier, a fallback one will be used.
 */
@property (nonatomic, copy, readonly) HUBComponentIdentifier *componentIdentifier;

/**
 *  The category of the component that this model should be rendered using
 *
 *  The Hub Framework uses the value of this property to create a fallback component in case no component could be
 *  created by any registered `HUBComponentFactory` for the model's `componentIdentifier`
 */
@property (nonatomic, copy, readonly) NSString *componentCategory;

/**
 *  Any identifier for the model's content
 *
 *  Useful when using some form of content management system to generate component content on the server side.
 *  This identifier enables you to track the content all the way from the server, to logs generated on the
 *  client side.
 */
@property (nonatomic, copy, nullable, readonly) NSString *contentIdentifier;

/**
 *  The index of the model, either within its parent or within the root list
 *
 *  Components that use nested models can use this property to determine which child to map a certain model to
 */
@property (nonatomic, readonly) NSUInteger index;

#pragma mark - Standard visual content

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

#pragma mark - Custom content

/**
 *  Dictionary containing image data objects that describe how to render any custom images for the component
 *
 *  The keys in this dictionary specify the identifiers of the images, that the component can use to determine their layout.
 *
 *  For default images, see `mainImagedata` and `backgroundImageData`.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id<HUBComponentImageData>> *customImageData;

/**
 *  Any custom data that the component should use
 *
 *  If a component has some specific customizability options they can be specified here. This is also a good place for additional
 *  metadata or properties that are not covered by his protocol, so that new data may be added without changing the framework itself.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject *> *customData;

#pragma mark - Metadata

/**
 *  Any URL that is the target of a user interaction with the component
 *
 *  When the user interacts with the component, the Hub Framework will attempt to open this URL through the application's
 *  standard "open URL" mechanism. The URL might point to an internal or external page, resource or trigger some form of
 *  action.
 */
@property (nonatomic, copy, nullable, readonly) NSURL *targetURL;

/**
 *  Any pre-computed model for a Hub view that is the target of `targetURL`
 *
 *  This property can be used to setup several views up-front, either partially or completely. In case this property is not nil,
 *  and the target view is a Hub Framework-powered view as well, the framework will automatically setup that view using this view
 *  model. Using this property might lead to a better user experience, since the user will be able to see a "skeleton" version of
 *  new views before the their content is loaded, rather than just seing a blank screen.
 *
 *  Once either remote or local content has been loaded for the target view, a new view model created from that content will replace
 *  this initial one.
 */
@property (nonatomic, copy, nullable, readonly) id<HUBViewModel> targetInitialViewModel;

/**
 *  Any data that should be logged alongside interactions or impressions for the component
 *
 *  The format of this dictionary is completely free form, but since at some point it will end up being serialized, make sure that
 *  it only contains serializable values.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject *> *loggingData;

/**
 *  Any date that is associated with the component
 *
 *  Some components may use this data to render some form of UI that illustrates the date, and external data API users might use it
 *  to take decisions based it.
 */
@property (nonatomic, strong, nullable, readonly) NSDate *date;

#pragma mark - Child models

/**
 *  Any component models that are children of this model
 *
 *  The Hub Framework supports nested components, but it’s up to each `HUBComponent` implementation to decide what to do
 *  with them. For example, when creating a carousel-like component, the children of that component might be the items that
 *  the carousel contains.
 */
@property (nonatomic, strong, nullable, readonly) NSArray<id<HUBComponentModel>> *childComponentModels;

@end

NS_ASSUME_NONNULL_END
