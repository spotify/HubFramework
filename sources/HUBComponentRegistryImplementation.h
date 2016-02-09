#import "HUBComponentRegistry.h"

@protocol HUBComponentFallbackHandler;
@protocol HUBComponent;
@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentRegistry` API
@interface HUBComponentRegistryImplementation : NSObject <HUBComponentRegistry>

/// The namespaced identifiers of all components this registry contains
@property (nonatomic, strong, readonly) NSArray<NSString *> *allComponentIdentifiers;

/**
 *  Initialize an instance of this class with a component fallback handler
 *
 *  @param fallbackHandler An object responsible for handling the case of an unrecognized component
 *         identifier. This object will be retained.
 */
- (instancetype)initWithFallbackHandler:(id<HUBComponentFallbackHandler>)fallbackHandler NS_DESIGNATED_INITIALIZER;

/**
 *  Return the component to use for a certain model
 *
 *  @param model The component model to retrieve the component for
 *
 *  @return A newly created component that is ready to use
 */
- (id<HUBComponent>)componentForModel:(id<HUBComponentModel>)model;

/**
 *  Return the component identifier to use for a certain model
 *
 *  @param model The component model to determine the component identifier for
 *
 *  @return Either the model's own `componentIdentifier`, or the identifier for a fallback
 *          component if the component that the model specifies does not exist in the registry.
 */
- (NSString *)componentIdentifierForModel:(id<HUBComponentModel>)model;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
