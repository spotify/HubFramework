#import "HUBActionHandler.h"
#import "HUBHeaderMacros.h"

@class HUBActionRegistryImplementation;
@class HUBInitialViewModelRegistry;
@class HUBViewModelLoaderImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Class handling actions for a Hub Framework powered-view, while wrapping any user-specified action handler
@interface HUBActionHandlerWrapper : NSObject <HUBActionHandler>

/**
 *  Initialize an instance of this class
 *
 *  @param actionHandler Any user-specified (either when setting up `HUBManager` or from a feature registration)
 *         action handler that this one should wrap.
 *  @param actionRegistry The registry to use to create actions
 *  @param initialViewModelRegistry The registry to use to get and set initial view models
 *  @param viewModelLoader The loader that will be used to load view models for the view that this handler is for
 */
- (instancetype)initWithActionHandler:(nullable id<HUBActionHandler>)actionHandler
                       actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
             initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      viewModelLoader:(HUBViewModelLoaderImplementation *)viewModelLoader HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
