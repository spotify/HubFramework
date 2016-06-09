#import "HUBComponentRegistry.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentFallbackHandler;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentRegistry` API
@interface HUBComponentRegistryImplementation : NSObject <HUBComponentRegistry>

/**
 *  Initialize an instance of this class with a component fallback handler
 *
 *  @param fallbackHandler The object to use to create fallback components
 */
- (instancetype)initWithFallbackHandler:(id<HUBComponentFallbackHandler>)fallbackHandler HUB_DESIGNATED_INITIALIZER;

/**
 *  Create a new component instance for a model
 *
 *  @param model The model to create a component for
 *  @param viewURI The URI of the view that the component will be used in
 *
 *  @return A newly created component that is ready to use. The component registry will first attempt
 *          to resolve a component factory for the model's `componentNamespace`, and ask it to create
 *          a component. However, if this fails, the registry will use its fallback handler to create
 *          a fallback component for the model's `componentCategory`.
 */
- (id<HUBComponent>)createComponentForModel:(id<HUBComponentModel>)model viewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
