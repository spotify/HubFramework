#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"
#import "HUBComponentIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;

@end

@implementation HUBManager

- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                               imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                        defaultComponentNamespace:(NSString *)defaultComponentNamespace
                            fallbackComponentName:(NSString *)fallbackComponentName
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
{
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(imageLoaderFactory != nil);
    NSParameterAssert(defaultComponentNamespace != nil);
    NSParameterAssert(fallbackComponentName != nil);
    NSParameterAssert(componentLayoutManager != nil);
    
    self = [super init];
    
    if (self) {
        HUBComponentIdentifier * const fallbackComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:defaultComponentNamespace
                                                                                                                  name:fallbackComponentName];
        
        _featureRegistry = [HUBFeatureRegistryImplementation new];
        _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackComponentIdentifier:fallbackComponentIdentifier];
        _JSONSchemaRegistry = [HUBJSONSchemaRegistryImplementation new];
        _connectivityStateResolver = connectivityStateResolver;
        
        _viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:_featureRegistry
                                                                                        JSONSchemaRegistry:_JSONSchemaRegistry
                                                                                 defaultComponentNamespace:defaultComponentNamespace
                                                                                 connectivityStateResolver:_connectivityStateResolver];
        
        _viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:_viewModelLoaderFactory
                                                                                             imageLoaderFactory:imageLoaderFactory
                                                                                              componentRegistry:self.componentRegistry
                                                                                         componentLayoutManager:componentLayoutManager];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
