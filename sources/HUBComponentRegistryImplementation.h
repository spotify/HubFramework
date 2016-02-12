#import "HUBComponentRegistry.h"

@class HUBComponentIdentifier;
@protocol HUBComponent;
@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentRegistry` API
@interface HUBComponentRegistryImplementation : NSObject <HUBComponentRegistry>

/**
 *  Initialize an instance of this class with a component fallback handler
 *
 *  @param fallbackComponentIdentifier An identifier of a component to use in case one couldn't be resolved
 *         for a certain identifier. This component identifier must be resolvable using one of the registered
 *         factories, once data loading starts, otherwise an assert is triggered.
 */
- (instancetype)initWithFallbackComponentIdentifier:(HUBComponentIdentifier *)fallbackComponentIdentifier NS_DESIGNATED_INITIALIZER;

/**
 *  Return a newly created component matching a given an identifier
 *
 *  @param identifier The identifier of a component to create
 *
 *  @return A newly created component that is ready to use. In case the supplied identifier didn’t result in
 *          a component (because a factory matching it’s `componentNamespace` couldn’t be found, or that factory
 *          returned `nil`), the registry will create a component based on its `fallbackComponentIdentifier`.
 *          If this operation also failed, an assert is triggered which should be considered an API user error.
 */
- (id<HUBComponent>)createComponentForIdentifier:(HUBComponentIdentifier *)identifier;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
