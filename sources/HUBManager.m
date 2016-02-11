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
                        defaultComponentNamespace:(NSString *)defaultComponentNamespace
                            fallbackComponentName:(NSString *)fallbackComponentName
{
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(defaultComponentNamespace != nil);
    NSParameterAssert(fallbackComponentName != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureRegistry = [HUBFeatureRegistryImplementation new];
    _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackNamespace:defaultComponentNamespace];
    _JSONSchemaRegistry = [HUBJSONSchemaRegistryImplementation new];
    _connectivityStateResolver = connectivityStateResolver;
    
    _viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:_featureRegistry
                                                                                    JSONSchemaRegistry:_JSONSchemaRegistry
                                                                             defaultComponentNamespace:defaultComponentNamespace
                                                                             connectivityStateResolver:_connectivityStateResolver];
    
    _viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:_viewModelLoaderFactory
                                                                                          componentRegistry:self.componentRegistry];
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
