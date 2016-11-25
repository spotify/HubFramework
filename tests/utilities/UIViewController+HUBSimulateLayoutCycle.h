#import <UIKit/UIKit.h>

/// Category that adds convenience APIs to `UIViewController`, for use in testing only
@interface UIViewController (HUBSimulateLayoutCycle)

/// Simulate the layout cycle of the view controller, loading its view - making it appear & layout its subviews
- (void)hub_simulateLayoutCycle;

@end
