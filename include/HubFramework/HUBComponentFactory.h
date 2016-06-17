#import <Foundation/Foundation.h>

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that create Hub Framework components
 *
 *  You implement a component factory to be able to integrate your component(s) with the framework.
 *  Each factory is registered with `HUBComponentRegistry` for a certain namespace, and will be used
 *  whenever a component model declares that namespace as part of its component identifier.
 */
@protocol HUBComponentFactory <NSObject>

/**
 *  Create a new component matching a name
 *
 *  @param name The name of the component to create
 *
 *  Returning `nil` from this method will cause a fallback component to be used, using the application's
 *  `HUBComponentFallbackHandler` and the component model's `HUBComponentCategory`.
 */
- (nullable id<HUBComponent>)createComponentForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
