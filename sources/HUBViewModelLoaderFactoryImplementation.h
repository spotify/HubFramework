#import "HUBViewModelLoaderFactory.h"
#import "HUBHeaderMacros.h"

@class HUBFeatureRegistryImplementation;
@class HUBJSONSchemaRegistryImplementation;
@class HUBInitialViewModelRegistry;
@class HUBComponentDefaults;
@class HUBFeatureRegistration;
@protocol HUBConnectivityStateResolver;

NS_ASSUME_NONNULL_BEGIN

/// Concerete implementation of the `HUBViewModelLoaderFactory` API
@interface HUBViewModelLoaderFactoryImplementation : NSObject <HUBViewModelLoaderFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param featureRegistry The feature registry to use to retrieve features registrations
 *  @param JSONSchemaRegistry The JSON schema registry to use to retrieve JSON schemas
 *  @param initialViewModelRegistry The registry to use to retrieve pre-computed view models for initial content
 *  @param componentDefaults The default values to use for component model builders created when loading view models
 *  @param connectivityStateResolver The object resolving connectivity states for created view model loaders
 */
- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver HUB_DESIGNATED_INITIALIZER;

/**
 *  Create a view model loader for a given view URI, using a feature registration
 *
 *  @param viewURI The view URI to create a view model loader for
 *  @param featureRegistration The feature registration object to use to setup the view model loader
 */
- (id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI
                                      featureRegistration:(HUBFeatureRegistration *)featureRegistration;

@end

NS_ASSUME_NONNULL_END
