#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"

@implementation HUBManager

- (instancetype)initWithComponentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _featureRegistry = [HUBFeatureRegistryImplementation new];
    _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler];
    _JSONSchemaRegistry = [HUBJSONSchemaRegistryImplementation new];
    
    return self;
}

@end
