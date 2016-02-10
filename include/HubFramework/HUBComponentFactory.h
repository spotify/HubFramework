#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class HUBComponentIdentifier;
@protocol HUBComponent;
@protocol HUBComponentModel;

/**
 *  Protocol defining the public API of a Hub component factory
 *
 *  A component factory is registered for a specific namespace in the `HUBComponentRegistry`.
 *  The registry will lookup the factory based on the namespace and query the factory for
 *  component instances based on the identifier.
 */
@protocol HUBComponentFactory

/**
 *  A list of of all the names served by the factory.
 *  A component is required to return a valid `HUBComponent` from `-componentFromName:` for any name present
 *  in the list. The registry will never call `-componentForName:` with any other name.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *allComponentNames;

/**
 *  Create a new component matching the name.
 *
 *  @param name The name for matching a component.
 *
 *  See `allComponentNames` for more information.
 */
- (id<HUBComponent>)componentForName:(NSString *)name;

/**
 *  Provide a fallback identifier for a specific model.
 *
 *  @param model The component model being displayed.
 *
 *  @return A fallback component identifier or `nil` to redirect it to the default factory.
 *
 *  If the `HUBComponentRegistry` encounters a name that isn't included in `allComponentNames` it will call this method
 *  in order to get a fallback component identifier for the model. This can either be used to provide a default
 *  fallback for old identifiers or when the model needs to be inspected to decide which component should handle it.
 *
 *  The default factory is required to return non-nil for all models.
 */
- (nullable HUBComponentIdentifier *)fallbackComponentIdentifierForModel:(id<HUBComponentModel>)model;

@end

NS_ASSUME_NONNULL_END
