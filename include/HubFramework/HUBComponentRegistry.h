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

@end

NS_ASSUME_NONNULL_END
