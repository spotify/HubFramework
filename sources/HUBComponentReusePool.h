#import "HUBHeaderMacros.h"

@protocol HUBComponentModel;
@class HUBComponentRegistryImplementation;
@class HUBComponentWrapperImplementation;
@class HUBComponentUIStateManager;

NS_ASSUME_NONNULL_BEGIN

/// Reuse pool that keeps track of component wrappers that may be reused for other models
@interface HUBComponentReusePool : NSObject

/**
 *  Initialize an instance of this class with a component registry and a UI state manager
 *
 *  @param componentRegistry The component registry to use to create new component instances
 *  @param UIStateManager The manager keeping track of component UI states
 */
- (instancetype)initWithComponentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                           UIStateManager:(HUBComponentUIStateManager *)UIStateManager HUB_DESIGNATED_INITIALIZER;

/**
 *  Add a component wrapper to the reuse pool, enabling it to be used for other models
 *
 *  @param componentWrapper The wrapper to add to the pool
 */
- (void)addComponentWrappper:(HUBComponentWrapperImplementation *)componentWrapper;

/**
 *  Retrieve a component wrapper from the pool for a given model
 *
 *  @param model The model to return a component wrapper for
 *
 *  This method will either return a reused wrapper, or create one if none existed in the pool.
 */
- (HUBComponentWrapperImplementation *)componentWrapperForModel:(id<HUBComponentModel>)model;

@end

NS_ASSUME_NONNULL_END
