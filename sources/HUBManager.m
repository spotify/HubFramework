#import "HUBManager.h"

#import "HUBComponentRegistryImplementation.h"

@implementation HUBManager

- (instancetype)initWithComponentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler];
    
    return self;
}

@end
