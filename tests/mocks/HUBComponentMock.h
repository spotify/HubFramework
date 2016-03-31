#import "HUBComponentWithChildren.h"
#import "HUBComponentWithImageHandling.h"

@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

/// Mocked component, for use in tests only
@interface HUBComponentMock : NSObject <HUBComponentWithChildren, HUBComponentWithImageHandling>

/// The layout traits the component should act like it's having
@property (nonatomic, strong) NSMutableSet<HUBComponentLayoutTrait *> *layoutTraits;

/// The size that the component should return as its preferred view size
@property (nonatomic) CGSize preferredViewSize;

/// The main image the component is currently displaying
@property (nonatomic, strong, readonly, nullable) id<HUBComponentImageData> mainImageData;

/// The number of times `updateViewForChangedSize` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfResizes;

/// The number of times `prepareViewForReuse` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfReuses;

/// Whether the component should act like it can handle images or not
@property (nonatomic) BOOL canHandleImages;

@end

NS_ASSUME_NONNULL_END
