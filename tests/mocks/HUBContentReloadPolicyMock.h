#import "HUBContentReloadPolicy.h"

/// Mocked content reload policy, for use in tests only
@interface HUBContentReloadPolicyMock : NSObject <HUBContentReloadPolicy>

/// Whether the reload policy should return that content should be reloaded
@property (nonatomic) BOOL shouldReload;

/// The number of requests that this mock has received
@property (nonatomic) NSUInteger numberOfRequests;

@end
