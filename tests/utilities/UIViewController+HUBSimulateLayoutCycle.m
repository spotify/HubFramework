#import "UIViewController+HUBSimulateLayoutCycle.h"

@implementation UIViewController (HUBSimulateLayoutCycle)

- (void)hub_simulateLayoutCycle
{
    // Load the view
    __unused UIView * const _ = self.view;
    
    [self viewWillAppear:YES];
    self.view.frame = CGRectMake(0, 0, 320, 400);
    [self viewDidLayoutSubviews];
}

@end
