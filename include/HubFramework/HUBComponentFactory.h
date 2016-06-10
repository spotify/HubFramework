#import <Foundation/Foundation.h>

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that create Hub Framework components
 *
 *  A component factory is registered for a specific namespace in the `HUBComponentRegistry`.
 *  The registry will lookup the factory based on the namespace and query the factory for
 *  component instances based on a component name.
 */
@protocol HUBComponentFactory <NSObject>

/**
 *  Create a new component matching a name
 *
 *  @param name The name of the component to create
 *
 *  Returning `nil` from this method will cause a fallback component to be used
 */
- (nullable id<HUBComponent>)createComponentForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
