#import <Foundation/Foundation.h>

@protocol HUBComponent;
@protocol HUBComponentFactory;
@class HUBComponentIdentifier;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub component registry
 *
 *  A component registry manages a series of registered `HUBComponentFactory` implementations,
 *  that are used to create components for Hub Framework-powered views. To integrate a component
 *  with the framework - implement a `HUBComponentFactory` and register it with the registry.
 *
 *  You don't conform to this protocol yourself, instead the application's `HUBManager` comes
 *  setup with a registry that you can use.
 */
@protocol HUBComponentRegistry <NSObject>

/**
 *  The component identifiers that have been declared as showcaseable
 *
 *  It's up to each component factory that has been registered with this registry to (optionally) declare
 *  an array of showcaseable component names (by conforming to `HUBComponentFactoryShowcaseNameProvider`),
 *  which will then be used to construct the component identifiers returned from this property.
 *
 *  The Hub Framework does not provide any built-in functionality for showcases, besides providing the
 *  component identifiers that have been declared as showcasable. Instead, it's up to each API user to build
 *  showcase functionality on top of this API.
 */
@property (nonatomic, strong, readonly) NSArray<HUBComponentIdentifier *> *showcaseableComponentIdentifiers;

/**
 *  Register a component factory with the Hub Framework
 *
 *  @param componentFactory The factory instance that will serve components matching `componentNamespace`.
 *
 *  The registered factory will be used to create components whenever a component model declared
 *  the given component namespace as part of its `componentIdentifier`.
 */
- (void)registerComponentFactory:(id<HUBComponentFactory>)componentFactory
                    forNamespace:(NSString *)componentNamespace;

/**
 *  Unregister a component factory from the Hub Framework
 *
 *  @param componentNamespace The namespace of the factory to unregister
 *
 *  After this method has been called, the Hub Framework will remove any factory found for the given namespace,
 *  opening it up to be registered again with another factory. If the given identifier does not exist, this
 *  method does nothing.
 */
- (void)unregisterComponentFactoryForNamespace:(NSString *)componentNamespace;

@end

NS_ASSUME_NONNULL_END
