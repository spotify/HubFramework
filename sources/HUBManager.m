#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;

@end

@implementation HUBManager

- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                               imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                                iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                         componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                       defaultContentReloadPolicy:(id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                 prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
                  appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory
{
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(imageLoaderFactory != nil);
    NSParameterAssert(iconImageResolver != nil);
    NSParameterAssert(defaultContentReloadPolicy != nil);
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(componentFallbackHandler != nil);
    
    self = [super init];
    
    if (self) {
        HUBComponentDefaults * const componentDefaults = [[HUBComponentDefaults alloc] initWithComponentNamespace:componentFallbackHandler.defaultComponentNamespace
                                                                                                    componentName:componentFallbackHandler.defaultComponentName
                                                                                                componentCategory:componentFallbackHandler.defaultComponentCategory];
        
        _connectivityStateResolver = connectivityStateResolver;
        _initialViewModelRegistry = [HUBInitialViewModelRegistry new];
        _featureRegistry = [HUBFeatureRegistryImplementation new];
        _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler];
        _JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
        
        _viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:_featureRegistry
                                                                                        JSONSchemaRegistry:_JSONSchemaRegistry
                                                                                  initialViewModelRegistry:_initialViewModelRegistry
                                                                                         componentDefaults:componentDefaults
                                                                                 connectivityStateResolver:_connectivityStateResolver
                                                                                         iconImageResolver:iconImageResolver
                                                                          prependedContentOperationFactory:prependedContentOperationFactory
                                                                           appendedContentOperationFactory:appendedContentOperationFactory];
        
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
