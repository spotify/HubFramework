#import "HUBComponent.h"

@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

/// Mocked component, for use in tests only
@interface HUBComponentMock : NSObject <HUBComponent>

/// The main image the component is currently displaying
@property (nonatomic, strong, readonly, nullable) id<HUBComponentImageData> mainImageData;

/// The number of times `prepareViewForReuse` has been called on this component
@property (nonatomic, readonly) NSUInteger numberOfReuses;

@end

NS_ASSUME_NONNULL_END
