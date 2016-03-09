#import <Foundation/Foundation.h>

@protocol HUBFeatureConfiguration;
@protocol HUBRemoteContentURLResolver;
@protocol HUBRemoteContentProviderFactory;
@protocol HUBLocalContentProviderFactory;
@protocol HUBFeatureRegistration;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub feature registry
 *
 *  A feature is the top-level entity in the Hub Framework, that is used to ecapsulate related views into a logical group.
 *  Views that belong to the same feature share a common root view URI as a prefix, as well as content providing logic
 *  and overrides.
 *
 *  You register features by creating `HUBFeatureConfiguration` objects through this registry, setting that object up
 *  according to your feature's requirements, and then finally passing it back to `-registerFeatureWithConfiguration:` to
 *  complete the registration process.
 *
 *  See `HUBFeatureConfiguration` for more information on how to configure a feature for use with the Hub Framework.
 */
@protocol HUBFeatureRegistry <NSObject>

/**
 *  Create a remote content URL resolver-based feature configuration object that is used to setup a feature with the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature (must be unique across the app)
 *  @param rootViewURI The root view URI of the feature (must be unique across the app)
 *  @param remoteContentURLResolver The remote content URL resolver that the feature should use
 *
 *  Use this way to create a configuration object in case you want to use the `HUBRemoteContentURLResolver` API to load your feature's
 *  content. If you want to customize the way content is loaded for your feature, use the content provider factory-based configuration
 *  factory method instead.
 *
 *  Once you've setup the returned configuration object according to your feature's requirements, pass it back to the registry
 *  using `-registerFeatureWithConfiguration:` to complete the registration process.
 *
 *  See `HUBFeatureConfiguration` and `HUBRemoteContentURLResolver` for more information.
 */
- (id<HUBFeatureConfiguration>)createConfigurationForFeatureWithIdentifier:(NSString *)featureIdentifier
                                                               rootViewURI:(NSURL *)rootViewURI
                                                  remoteContentURLResolver:(id<HUBRemoteContentURLResolver>)remoteContentURLResolver;

/**
 *  Create a content provider-based feature configuration object that is used to setup a feature with the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature (must be unique across the app)
 *  @param rootViewURI The root view URI of the feature (must be unique across the app)
 *  @param remoteContentProviderFactory Any factory that creates remote content providers for the feature
 *  @param localContentProviderFactory Any factory that creates local content providers for the feature
 *
 *  Use this way to create a configuration object in case you intend to implement a custom remote and/or local content provider.
 *  If your feature should use the `HUBRemoteContentURLResolver` API instead, use the other configuration factory method.
 *
 *  Once you've setup the returned configuration object according to your feature's requirements, pass it back to the registry
 *  using `-registerFeatureWithConfiguration:` to complete the registration process.
 *
 *  See `HUBFeatureConfiguration`, `HUBRemoteContentProviderFactory` and `HUBLocalContentProviderFactory` for more information.
 */
- (id<HUBFeatureConfiguration>)createConfigurationForFeatureWithIdentifier:(NSString *)featureIdentifier
                                                               rootViewURI:(NSURL *)rootViewURI
                                              remoteContentProviderFactory:(nullable id<HUBRemoteContentProviderFactory>)remoteContentProviderFactory
                                               localContentProviderFactory:(nullable id<HUBLocalContentProviderFactory>)localContentProviderFactory;


/**
 *  Register a feature with the Hub Framework using a configuration object
 *
 *  @param configuration The configuration object to use to register the feature
 *
 *  Once the configuration object has been passed to this method, the registration process is complete and additional changes to
 *  the configuration object will not be taken into consideration. Registering a feature with the same root view URI as one that is
 *  already registered is considered a severe error and will trigger an assert.
 */
- (void)registerFeatureWithConfiguration:(id<HUBFeatureConfiguration>)configuration;

/**
 *  Unregister a feature from the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature to unregister
 *
 *  After this method has been called, The Hub Framework will remove all information stored for the given identifier, and
 *  open it up to be registered again for another feature. If the given identifier does not exist, this method does nothing.
 */
- (void)unregisterFeatureWithIdentifier:(NSString *)featureIdentifier;

@end

NS_ASSUME_NONNULL_END
