#import "HUBComponentLayoutManager.h"

/// Mocked component layout manager, for use in tests only
@interface HUBComponentLayoutManagerMock : NSObject <HUBComponentLayoutManager>

/// Map of content edge margins to use (for all edges) for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait *> *, NSNumber *> *contentEdgeMarginsForLayoutTraits;

/// Map of header margins to use for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait *> *, NSNumber *> *headerMarginsForLayoutTraits;

/// Map of horizontal component margins to use for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait *> *, NSNumber *> *horizontalComponentMarginsForLayoutTraits;

/// Map of vertical component margins to use for a set of layout traits
@property (nonatomic, strong, readonly) NSMutableDictionary<NSSet<HUBComponentLayoutTrait *> *, NSNumber *> *verticalComponentMarginsForLayoutTraits;

@end
