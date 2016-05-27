#import "HUBConnectivityStateResolver.h"

/// Mocked connectivity state resolver, for use in tests only
@interface HUBConnectivityStateResolverMock : NSObject <HUBConnectivityStateResolver>

/// The state that the resolver is always returning
@property (nonatomic) HUBConnectivityState state;

/// Call all observers, simulating a change in connectivity state
- (void)callObservers;

@end
