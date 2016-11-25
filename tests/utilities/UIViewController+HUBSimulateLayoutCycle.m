#import "UIViewController+HUBSimulateLayoutCycle.h"

@implementation UIViewController (HUBSimulateLayoutCycle)

- (void)hub_simulateLayoutCycle
{
    [self loadView];
    [self viewDidLoad];
    [self viewWillAppear:YES];
    self.view.frame = CGRectMake(0, 0, 320, 400);
    [self viewDidLayoutSubviews];
}

@end
