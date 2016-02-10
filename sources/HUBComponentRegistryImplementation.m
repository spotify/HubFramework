#import "HUBComponentRegistryImplementation.h"

#import "HUBComponent.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentFactory.h"
#import "HUBComponentModel.h"

@interface HUBComponentRegistryImplementation ()
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBComponentFactory>> *componentFactories;
@property (nonatomic, copy, readonly) NSString *fallbackNamespace;

@end

@implementation HUBComponentRegistryImplementation

- (instancetype)initWithFallbackNamespace:(NSString *)fallbackNamespace
{
    if (!(self = [super init])) {
        return nil;
    }

    _componentFactories = [NSMutableDictionary new];
    _fallbackNamespace = [fallbackNamespace copy];

    return self;
}

#pragma mark - API

- (NSArray<NSString *> *)allComponentIdentifiers
{
    NSMutableArray * const componentIdentifiers = [NSMutableArray new];

    [self.componentFactories enumerateKeysAndObjectsUsingBlock:^(NSString *componentNamespace, id<HUBComponentFactory> factory, BOOL *stop) {
        for (NSString * const name in factory.allComponentNames) {
            HUBComponentIdentifier * const identifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentNamespace
                                                                                                     name:name];
            [componentIdentifiers addObject:identifier];
        }
    }];

    return [componentIdentifiers copy];
}

- (id<HUBComponent>)componentForModel:(id<HUBComponentModel>)model
{
    HUBComponentIdentifier * const identifier = [self componentIdentifierForModel:model];
    NSString * const componentNamespace = identifier.componentNamespace;

    id<HUBComponentFactory> const factory = self.componentFactories[componentNamespace];

    id<HUBComponent> component = [factory componentForName:identifier.componentName];
    NSAssert(component != nil, @"No component could be created for identifier (%@) - make sure that at least the default factory always returns a component in all cases.", identifier);

    return component;
}

- (HUBComponentIdentifier *)componentIdentifierForModel:(id<HUBComponentModel>)model
{
    HUBComponentIdentifier * modelComponentIdentifier = model.componentIdentifier;
    if (!modelComponentIdentifier) {
        return [self defaultComponentIdentifierForModel:model];
    }

    NSString * const componentNamespace = modelComponentIdentifier.componentNamespace;
    NSString * const componentName = modelComponentIdentifier.componentName;

    if (componentNamespace) {
        id<HUBComponentFactory> const factory = self.componentFactories[componentNamespace];
        if ([factory.allComponentNames containsObject:componentName]) {
            return modelComponentIdentifier;
        }
        HUBComponentIdentifier *identifier = [factory fallbackComponentIdentifierForModel:model];
        if (identifier) {
            return [[HUBComponentIdentifier alloc] initWithNamespace:identifier.componentNamespace ?: componentNamespace
                                                                name:identifier.componentName];
        }
    }

    return [[HUBComponentIdentifier alloc] initWithNamespace:self.fallbackNamespace name:componentName];
}

- (HUBComponentIdentifier *)defaultComponentIdentifierForModel:(id<HUBComponentModel>)model
{
    id<HUBComponentFactory> const factory = self.componentFactories[self.fallbackNamespace];

    HUBComponentIdentifier * const identifier = [factory fallbackComponentIdentifierForModel:model];
    NSAssert(identifier, @"The fallback factory needs to return a valid fallback component identifier");

    return [[HUBComponentIdentifier alloc] initWithNamespace:identifier.componentNamespace ?: self.fallbackNamespace
                                                        name:identifier.componentName];
}

#pragma mark - HUBComponentRegistry

- (void)registerComponentFactory:(id<HUBComponentFactory>)componentFactory forNamespace:(NSString *)componentNamespace
{
    NSAssert(self.componentFactories[componentNamespace] == nil,
             @"Attempted to register a component factory for a namespace that is already registered: %@",
             componentNamespace);

    self.componentFactories[componentNamespace] = componentFactory;
}

@end
