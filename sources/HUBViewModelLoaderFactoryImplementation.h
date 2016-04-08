#import "HUBViewModelLoaderFactory.h"
#import "HUBHeaderMacros.h"

@class HUBFeatureRegistryImplementation;
@class HUBJSONSchemaRegistryImplementation;
@class HUBInitialViewModelRegistry;
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
 *  @param defaultComponentNamespace The default namespace that components in loaded view models should have
 *  @param connectivityStateResolver The object resolving connectivity states for created view model loaders
 */
- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
               initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
