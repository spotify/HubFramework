#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;

@end

@implementation HUBManager

- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                               imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                        defaultComponentNamespace:(NSString *)defaultComponentNamespace
                            fallbackComponentName:(NSString *)fallbackComponentName
                       defaultContentReloadPolicy:(id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
{
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(imageLoaderFactory != nil);
    NSParameterAssert(defaultComponentNamespace != nil);
    NSParameterAssert(fallbackComponentName != nil);
    NSParameterAssert(componentLayoutManager != nil);
    
    self = [super init];
    
    if (self) {
        _connectivityStateResolver = connectivityStateResolver;
        _initialViewModelRegistry = [HUBInitialViewModelRegistry new];
        
        HUBComponentDefaults * const componentDefaults = [[HUBComponentDefaults alloc] initWithComponentNamespace:defaultComponentNamespace
                                                                                                    componentName:fallbackComponentName];
        
        HUBComponentIdentifier * const fallbackComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentDefaults.componentNamespace
                                                                                                                  name:componentDefaults.componentName];
        
        _featureRegistry = [HUBFeatureRegistryImplementation new];
        _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackComponentIdentifier:fallbackComponentIdentifier];
        _JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults];
        
        _viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:_featureRegistry
                                                                                        JSONSchemaRegistry:_JSONSchemaRegistry
                                                                                  initialViewModelRegistry:_initialViewModelRegistry
                                                                                         componentDefaults:componentDefaults
                                                                                 connectivityStateResolver:_connectivityStateResolver];
        
        _viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:_viewModelLoaderFactory
                                                                                             imageLoaderFactory:imageLoaderFactory
                                                                                                featureRegistry:_featureRegistry
                                                                                              componentRegistry:_componentRegistry
                                                                                       initialViewModelRegistry:_initialViewModelRegistry
                                                                                     defaultContentReloadPolicy:defaultContentReloadPolicy
                                                                                         componentLayoutManager:componentLayoutManager];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
