#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;

@end

@implementation HUBManager

- (instancetype)initWithComponentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                       connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureRegistry = [HUBFeatureRegistryImplementation new];
    _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler];
    _JSONSchemaRegistry = [HUBJSONSchemaRegistryImplementation new];
    _connectivityStateResolver = connectivityStateResolver;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
