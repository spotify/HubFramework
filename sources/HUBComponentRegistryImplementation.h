#import "HUBComponentRegistry.h"
#import "HUBComponentShowcaseManager.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentFallbackHandler;
@protocol HUBIconImageResolver;
@class HUBComponentDefaults;
@class HUBJSONSchemaRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentRegistry` and `HUBComponentShowcaseManager` APIs
@interface HUBComponentRegistryImplementation : NSObject <HUBComponentRegistry, HUBComponentShowcaseManager>

/**
 *  Initialize an instance of this class with a component fallback handler
 *
 *  @param fallbackHandler The object to use to create fallback components
 *  @param componentDefaults The default component values to use for component models
 *  @param JSONSchemaRegistry The JSON schema registry used in this instance of the Hub Framework
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithFallbackHandler:(id<HUBComponentFallbackHandler>)fallbackHandler
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

/**
 *  Create a new component instance for a model
 *
 *  @param model The model to create a component for
 *
 *  @return A newly created component that is ready to use. The component registry will first attempt
 *          to resolve a component factory for the model's `componentNamespace`, and ask it to create
 *          a component. However, if this fails, the registry will use its fallback handler to create
 *          a fallback component for the model's `componentCategory`.
 */
- (id<HUBComponent>)createComponentForModel:(id<HUBComponentModel>)model;

@end

NS_ASSUME_NONNULL_END
