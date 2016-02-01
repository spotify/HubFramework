#import <Foundation/Foundation.h>

@protocol HUBComponentImageData;

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
@protocol HUBComponentModel <NSObject>

#pragma mark - Identifiers

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
 *  The component identifier should be fully namespaced and match a namespace:component
 *  combination of a component that has been registered with the Hub Framework.
 *
 *  If no component can be resolved for this identifier, or if the identifier is nil, a fallback one will be used.
 */
@property (nonatomic, copy, nullable, readonly) NSString *componentIdentifier;

/**
 *  Any identifier for the model's content
 *
 *  Useful when using some form of content management system to generate component content on the server side.
 *  This identifier enables you to track the content all the way from the server, to logs generated on the
 *  client side.
 */
@property (nonatomic, copy, nullable, readonly) NSString *contentIdentifier;

#pragma mark - Visual content

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

/**
 *  Dictionary containing image data objects that describe how to render any custom images for the component
 *
 *  The keys in this dictionary specify the identifiers of the images, that the component can use to determine their layout.
 *
 *  For default images, see `mainImagedata` and `backgroundImageData`.
 */
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id<HUBComponentImageData>> *customImageData;

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
 *  Any custom data that the component should use
 *
 *  If a component has some specific customizability options they can be specified here. This is also a good place for additional
 *  metadata or properties that are not covered by his protocol, so that new data may be added without changing the framework itself.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject *> *customData;

/**
 *  Any data that should be logged alongside interactions or impressions for the component
 *
 *  The format of this dictionary is completely free form, but since at some point it will end up being serialized, make sure that
 *  it only contains serializable values.
 */
@property (nonatomic, strong, nullable, readonly) NSDictionary<NSString *, NSObject<NSCoding> *> *loggingData;

/**
 *  Any date that is associated with the component
 *
 *  Some components may use this data to render some form of UI that illustrates the date, and external data API users might use it
 *  to take decisions based it.
 */
@property (nonatomic, strong, nullable, readonly) NSDate *date;

@end

NS_ASSUME_NONNULL_END
