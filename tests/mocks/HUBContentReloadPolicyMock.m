#import "HUBContentReloadPolicyMock.h"

@implementation HUBContentReloadPolicyMock

- (BOOL)shouldReloadContentForViewWithCurrentViewModel:(id<HUBViewModel>)currentViewModel
{
    self.numberOfRequests++;
    return self.shouldReload;
}

@end
