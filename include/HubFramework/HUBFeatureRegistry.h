#import <Foundation/Foundation.h>

@protocol HUBFeatureConfiguration;
@protocol HUBContentProviderFactory;
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
 *  Create a configuration object used to setup a feature for use with the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature. Must be unique across the app.
 *  @param rootViewURI The view URI that all views of the feature have as a prefix. Must be unique across the app.
 *  @param contentProviderFactories The factories that should be used to create content providers for views of the feature.
 *         The order of the array will determine which order the factories will be called in when creating content providers,
 *         which in turn will determine the content loading order.
 */
- (id<HUBFeatureConfiguration>)createConfigurationForFeatureWithIdentifier:(NSString *)featureIdentifier
                                                               rootViewURI:(NSURL *)rootViewURI
                                                  contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories;

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
