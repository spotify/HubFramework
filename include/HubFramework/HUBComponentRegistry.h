#import <Foundation/Foundation.h>

@protocol HUBComponent;
@protocol HUBComponentFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub component registry
 *
 *  A component registry is an object that keeps track of the components registered
 *  with an instance of the Hub Framework.
 */
@protocol HUBComponentRegistry <NSObject>

/**
 *  Register a component factory with the Hub Framework
 *
 *  @param componentFactory The factory instance that will serve components matching `componentNamespace`.
 *
 *  The components will be identifiable using the namespace and component identifier
 *  in combination, separated by a colon (:), like this: `namespace:component`. This mechanism helps
 *  prevent collisions between components registered from different parts of the app.
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
