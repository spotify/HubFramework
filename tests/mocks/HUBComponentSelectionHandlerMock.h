#import "HUBComponentSelectionHandler.h"

/// Mocked component selection handler, for use in tests only
@interface HUBComponentSelectionHandlerMock : NSObject <HUBComponentSelectionHandler>

/// The component models that was sent to the selection handler
@property (nonatomic, strong, readonly) NSArray<id<HUBComponentModel>> *selectedComponentModels;

/// Whether the selection handler should act like it handles selections
@property (nonatomic, assign) BOOL handlesSelection;

@end
