#import "HUBComponentSelectionHandler.h"
#import "HUBHeaderMacros.h"

@class HUBInitialViewModelRegistry;

NS_ASSUME_NONNULL_BEGIN

/// Class performing selection handling for components, while wrapping any feature-specified custom selection handler
@interface HUBComponentSelectionHandlerWrapper : NSObject <HUBComponentSelectionHandler>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param selectionHandler Any custom selection handler defined by the feature using this object
 *  @param initialViewModelRegistry The registry keeping track of initial view models
 */
- (instancetype)initWithSelectionHandler:(nullable id<HUBComponentSelectionHandler>)selectionHandler
                initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
