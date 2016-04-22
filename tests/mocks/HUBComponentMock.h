#import "HUBComponentWithChildren.h"
#import "HUBComponentWithImageHandling.h"
#import "HUBComponentViewObserver.h"

@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

/// Mocked component, for use in tests only
@interface HUBComponentMock : NSObject <HUBComponentWithChildren, HUBComponentWithImageHandling, HUBComponentViewObserver>

/// The layout traits the component should act like it's having
@property (nonatomic, strong) NSMutableSet<HUBComponentLayoutTrait *> *layoutTraits;

/// The size that the component should return as its preferred view size
@property (nonatomic) CGSize preferredViewSize;

/// The view that the component is using to render its content. Reset on `-loadView`.
@property (nonatomic, strong, nullable) UIView *view;

/// The main image the component is currently displaying
@property (nonatomic, strong, readonly, nullable) id<HUBComponentImageData> mainImageData;

/// The number of times `viewDidResize` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfResizes;

/// The number of times `viewWillAppear` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfAppearances;

/// The number of times `prepareViewForReuse` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfReuses;

/// Whether the component should act like it can handle images or not
@property (nonatomic) BOOL canHandleImages;

/// Whether the component should act like it is a view observer or not
@property (nonatomic) BOOL isViewObserver;

@end

NS_ASSUME_NONNULL_END
