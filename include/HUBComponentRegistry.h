#import <Foundation/Foundation.h>

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub component registry
 *
 *  A component registry is an object that keeps track of the components registered
 *  with an instance of the Hub Framework.
 */
@protocol HUBComponentRegistry <NSObject>

/**
 *  Register a group of components with the Hub Framework
 *
 *  @param components A dictionary containing components to register. The keys of the dictionary
 *         specifies the identifiers for the components.
 *  @param componentNamespace The namespace under which to register the components. The namespace
 *         must be unique across the app.
 *
 *  The components you register will be identifiable using the namespace and component identifier
 *  in combination, separated by a colon (:), like this: `namespace:component`. This mechanism helps
 *  prevent collisions between components registered from different parts of the app.
 *
 *  If a conflict does occur for any of the components (the exact same namespace:component combination
 *  has already been registered), an assert will be triggered.
 */
- (void)registerComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components
              forNamespace:(NSString *)componentNamespace;

@end

NS_ASSUME_NONNULL_END
