#import "HUBComponentSelectionHandler.h"
#import "HUBComponentSelectionContext.h"

/// Mocked component selection handler, for use in tests only
@interface HUBComponentSelectionHandlerMock : NSObject <HUBComponentSelectionHandler>

/// The selection contexts that were sent to the selection handler
@property (nonatomic, strong, readonly) NSArray<id<HUBComponentSelectionContext>> *selectionContexts;

/// Whether the selection handler should act like it handles selections
@property (nonatomic, assign) BOOL handlesSelection;

@end
