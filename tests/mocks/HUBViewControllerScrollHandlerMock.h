#import "HUBViewControllerScrollHandler.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked view controller scroll handler, for use in tests only
@interface HUBViewControllerScrollHandlerMock : NSObject <HUBViewControllerScrollHandler>

/// Whether the handler should return that scroll indicators should be shown
@property (nonatomic, assign) BOOL shouldShowScrollIndicators;

/// Whether the handler should return that content insets should automatically be adjusted
@property (nonatomic, assign) BOOL shouldAutomaticallyAdjustContentInsets;

/// The scroll deceleration rate that the handler should return
@property (nonatomic, assign) CGFloat scrollDecelerationRate;

/// The content insets that the handler should return
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/// The target content offset that the handler should return
@property (nonatomic, assign) CGPoint targetContentOffset;

/// The last content rect that was sent to the handler when scrolling started
@property (nonatomic, assign, readonly) CGRect startContentRect;

@end

NS_ASSUME_NONNULL_END
