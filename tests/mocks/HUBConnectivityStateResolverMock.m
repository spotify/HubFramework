#import "HUBConnectivityStateResolverMock.h"

@implementation HUBConnectivityStateResolverMock

- (HUBConnectivityState)resolveConnectivityState
{
    return self.state;
}

@end
