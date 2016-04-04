#import <Foundation/Foundation.h>

@protocol HUBContentProviderFactory;
@protocol HUBViewURIQualifier;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub feature registry
 *
 *  A feature is the top-level entity in the Hub Framework, that is used to ecapsulate related views into a logical group.
 *  Views that belong to the same feature share a common root view URI as a prefix, as well as content providing logic
 *  and overrides.
 */
@protocol HUBFeatureRegistry <NSObject>

/**
 *  Register a feature with the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature. Used for logging & error messages. Must be unique across the app.
 *  @param rootViewURI The root view URI of the feature. Must be unique across the app. The Hub Framework will create view
 *         controllers on behalf of this feature for every view URI that has this URI as a prefix. To tweak this behavior,
 *         pass a `viewURIQualifier`.
 *  @param contentProviderFactories The factories that should be used to create content providers for the feature's views.
 *         The order of the factories will determine the order in which the created content providers are called each time a
 *         view that is a part of the feature will load data. See `HUBContentProviderFactory` for more information.
 *  @param customJSONSchemaIdentifier Any identifier of a custom schema to use to parse JSON data. If nil, the default
 *         schema will be used. Register your custom schema using `HUBJSONSchemaRegistry`. See `HUBJSONSchema` for more info.
 *  @param viewURIQualifier Any view URI qualifier that the feature should use. A view URI qualifier can be used to dynamically
 *         enable/disable certain views of the feature. For more information, see `HUBViewURIQualifier`.
 *
 *  Registering a feature with the same root view URI as one that is already registered is considered a severe error and
 *  will trigger an assert.
 */
- (void)registerFeatureWithIdentifier:(NSString *)featureIdentifier
                          rootViewURI:(NSURL *)rootViewURI
             contentProviderFactories:(NSArray<id<HUBContentProviderFactory>> *)contentProviderFactories
           customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                     viewURIQualifier:(nullable id<HUBViewURIQualifier>)viewURIQualifier;

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
