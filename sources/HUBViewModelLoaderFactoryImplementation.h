#import "HUBViewModelLoaderFactory.h"

@class HUBFeatureRegistryImplementation;
@class HUBJSONSchemaRegistryImplementation;
@protocol HUBConnectivityStateResolver;

NS_ASSUME_NONNULL_BEGIN

/// Concerete implementation of the `HUBViewModelLoaderFactory` API
@interface HUBViewModelLoaderFactoryImplementation : NSObject <HUBViewModelLoaderFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param featureRegistry The feature registry to use to retrieve features registrations
 *  @param JSONSchemaRegistry The JSON schema registry to use to retrieve JSON schemas
 *  @param defaultComponentNamespace The default namespace that components in loaded view models should have
 *  @param connectivityStateResolver The object resolving connectivity states for created view model loaders
 */
- (instancetype)initWithFeatureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
              connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
