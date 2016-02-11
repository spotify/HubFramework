#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;

@end

@implementation HUBManager

- (instancetype)initWithFallbackComponentNamespace:(NSString *)fallbackComponentNamespace
                         connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureRegistry = [HUBFeatureRegistryImplementation new];
    _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackNamespace:fallbackComponentNamespace];
    _JSONSchemaRegistry = [HUBJSONSchemaRegistryImplementation new];
    _connectivityStateResolver = connectivityStateResolver;
    
    _viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:_featureRegistry
                                                                                    JSONSchemaRegistry:_JSONSchemaRegistry
                                                                             connectivityStateResolver:_connectivityStateResolver];
    
    _viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:_viewModelLoaderFactory
                                                                                          componentRegistry:self.componentRegistry];
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
