#import "HUBComponentRegistryImplementation.h"

#import "HUBComponent.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentFactory.h"
#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentRegistryImplementation ()

@property (nonatomic, copy, readonly) HUBComponentIdentifier *fallbackComponentIdentifier;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBComponentFactory>> *componentFactories;

@end

@implementation HUBComponentRegistryImplementation

- (instancetype)initWithFallbackComponentIdentifier:(HUBComponentIdentifier *)fallbackComponentIdentifier
{
    self = [super init];
    
    if (self) {
        _fallbackComponentIdentifier = [fallbackComponentIdentifier copy];
        _componentFactories = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (id<HUBComponent>)createComponentForIdentifier:(HUBComponentIdentifier *)identifier
{
    id<HUBComponentFactory> const factory = self.componentFactories[identifier.componentNamespace];
    id<HUBComponent> const component = [factory createComponentForName:identifier.componentName];
    
    if (component != nil) {
        return component;
    }
    
    return [self createFallbackComponent];
}

#pragma mark - HUBComponentRegistry

- (void)registerComponentFactory:(id<HUBComponentFactory>)componentFactory forNamespace:(NSString *)componentNamespace
{
    NSAssert(self.componentFactories[componentNamespace] == nil,
             @"Attempted to register a component factory for a namespace that is already registered: %@",
             componentNamespace);

    self.componentFactories[componentNamespace] = componentFactory;
}

#pragma mark - Priate utilities

- (id<HUBComponent>)createFallbackComponent
{
    id<HUBComponentFactory> const fallbackFactory = self.componentFactories[self.fallbackComponentIdentifier.componentNamespace];
    id<HUBComponent> const fallbackComponent = [fallbackFactory createComponentForName:self.fallbackComponentIdentifier.componentName];
    
    NSAssert(fallbackComponent != nil,
             @"A fallback component could not be created by HubComponentRegistry.\
             This is a severe error. Make sure that the defaultComponentNamespace:fallbackComponentName\
             combination passed to HubManager always results in a component. Current fallback component identifier: %@",
             self.fallbackComponentIdentifier);
    
    return fallbackComponent;
}

@end

NS_ASSUME_NONNULL_END
