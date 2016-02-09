#import "HUBComponentRegistryImplementation.h"

#import "HUBComponent.h"
#import "HUBComponentModel.h"
#import "HUBComponentFallbackHandler.h"

@interface HUBComponentRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBComponent>> *componentsByIdentifier;
@property (nonatomic, strong, readonly) id<HUBComponentFallbackHandler> fallbackHandler;

@end

@implementation HUBComponentRegistryImplementation

- (instancetype)initWithFallbackHandler:(id<HUBComponentFallbackHandler>)fallbackHandler
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _componentsByIdentifier = [NSMutableDictionary new];
    _fallbackHandler = fallbackHandler;
    
    return self;
}

#pragma mark - API

- (NSArray<NSString *> *)allComponentIdentifiers
{
    return self.componentsByIdentifier.allKeys;
}

- (id<HUBComponent>)componentForModel:(id<HUBComponentModel>)model
{
    NSString * const componentIdentifier = [self componentIdentifierForModel:model];
    id<HUBComponent> const component = [self.componentsByIdentifier objectForKey:componentIdentifier];
    
    NSAssert(component != nil,
             @"Fatal Hub Framework error. Could not retrieve component for \"%@\". Check your fallback code.",
             componentIdentifier);
    
    return component;
}

- (NSString *)componentIdentifierForModel:(id<HUBComponentModel>)model
{
    NSString * const modelComponentIdentifier = model.componentIdentifier;
    
    if ([self.componentsByIdentifier objectForKey:modelComponentIdentifier] != nil) {
        return modelComponentIdentifier;
    }
    
    return [self.fallbackHandler fallbackComponentIdentifierForModel:model];
}

#pragma mark - HUBComponentRegistry

- (void)registerComponents:(NSDictionary<NSString *,id<HUBComponent>> *)components forNamespace:(NSString *)componentNamespace
{
    for (NSString * const componentIdentifier in components.allKeys) {
        id<HUBComponent> const component = [components objectForKey:componentIdentifier];
        
        NSString * const namespacedComponentIdentifier = [NSString stringWithFormat:@"%@:%@", componentNamespace, componentIdentifier];
        
        NSAssert([self.componentsByIdentifier objectForKey:namespacedComponentIdentifier] == nil,
                 @"Attempted to register a component for an identifier that is already registered: %@",
                 namespacedComponentIdentifier);
        
        [self.componentsByIdentifier setObject:component forKey:namespacedComponentIdentifier];
    }
}

@end
