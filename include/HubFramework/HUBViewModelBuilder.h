#import <Foundation/Foundation.h>

@protocol HUBComponentModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a builder that builds view model objects
 *
 *  This builder acts like a mutable model counterpart for `HUBViewModel`, with the key difference that they
 *  are not related by inheritance.
 *
 *  If a remote content provider is used, a view model builder object comes pre-populated with content derived
 *  from the JSON data the remote content provider downloaded.
 *
 *  For more information regarding the properties that this builder enables you to set, see the documentation
 *  for `HUBViewModel`.
 */
@protocol HUBViewModelBuilder <NSObject>

/**
 *  Whether this builder is currently empty, and does not contain any content
 *
 *  As soon as any header or body component model has been added to this builder, it is no longer considered empty
 */
@property (nonatomic, readonly) BOOL isEmpty;

/**
 *  The identifier that the view should have
 *
 *  The value of this property doesn't have any specific format or constraints and doesn't explicitly need to be
 *  unique - but for logging, UI instrumentation and identification purposes, it's definitely recommended.
 *
 *  The default value of this property is either a view identifier derived from remote content JSON data, or the
 *  `UUIDString` of a new `NSUUID`.
 */
@property (nonatomic, copy) NSString *viewIdentifier;

/**
 *  The identifier of the feature that the view should logically belong to
 *
 *  This property can be used to group views together, to be able to reason about them as a feature. It can
 *  optionally be used for logging and UI instrumentation.
 *
 *  The default value of this property is the identifier of the Hub Framework feature that the view will belong
 *  to, or any explicit value that any remote content JSON data contained.
 */
@property (nonatomic, copy) NSString *featureIdentifier;

/**
 *  The identifier of any entity that the view will represent
 *
 *  The value of this property doesn't have any specific format or constraints, and is mainly used for logging and
 *  UI instrumentation.
 *
 *  An example of an entity identifier is some form of identifier for consumable media (in the context of the
 *  Spotify app, it could be the URI of an album or artist, for example).
 */
@property (nonatomic, copy, nullable) NSString *entityIdentifier;

/**
 *  The title that the view should have in the navigation bar
 *
 *  In case the view has a component-based header, the value of this property is ignored by the framework.
 */
@property (nonatomic, copy, nullable) NSString *navigationBarTitle;

/**
 *  The builder to use to build a model for the view's header component
 *
 *  If you plan to add a header to your view, you use this builder to setup the component that will make up the header.
 *  You need to assign a `componentIdentifier` to this builder in case you want a header to be displayed, otherwise, this
 *  builder will be ignored and a UINavigationBar-based header will be used instead of a component-based one.
 *
 *  In case no identifier is explicity defined for the view's header component model, it will use "header" as the default.
 */
@property (nonatomic, strong, readonly) id<HUBComponentModelBuilder> headerComponentModelBuilder;

/**
 *  Any HTTP URL from which data can be downloaded to extend the view model
 *
 *  You can use this property to implement pagination for your view's content. When the user has scrolled to the
 *  bottom of a view, and that view model's extension URL != nil, the Hub Framework will automatically ask its remote
 *  content provider to download JSON from this URL, and use it to extend the current view model.
 */
@property (nonatomic, copy, nullable) NSURL *extensionURL;

/**
 *  Any custom data that should be associated with the view model
 *
 *  You can use this property to pass any information along in the content loading process, into the view model itself.
 *  That data may later be used to make decisions in a view's delegate. It's useful for simple customization, but for
 *  extended use consider making a contribution to the main `HUBViewModel` API instead, if it's some piece of data that
 *  is considered useful for other API users as well.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *customData;

/**
 *  Add content from JSON data to this builder
 *
 *  @param JSONData The JSON data to add
 *
 *  The builder will use it's feature's `HUBJSONSchema` to parse the data that was added, and return any error that
 *  occured while doing so, or nil if the operation was completed successfully.
 */
- (nullable NSError *)addJSONData:(NSData *)JSONData;

/**
 *  Return whether this builder contains a builder for a body component model with a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForBodyComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Get or create a builder for a body component model with a certain identifier
 *
 *  @param identifier The identifier that the component model should have
 *
 *  @return If a builder already exists for the supplied identifier, then it's returned. Otherwise a new builder is
 *  created, which can be used to build a body component model. Since this method lazily creates a builder in case
 *  one doesn't already exist, use the `-builderExistsForBodyComponentModelWithIdentifier:` API instead if you simply
 *  wish to check for the existance of a builder. See `HUBComponentModelBuilder` for more information.
 */
- (id<HUBComponentModelBuilder>)builderForBodyComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Remove a builder for a body component with a certain identifier
 *
 *  @param identifier The identifier of the component model builder to remove
 */
- (void)removeBuilderForBodyComponentModelWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
