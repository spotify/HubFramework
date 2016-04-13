#import "HUBComponentDefaults.h"

/// Category adding convenience APIs for use in unit tests only
@interface HUBComponentDefaults (Testing)

/// Return a set of defaults to use in tests
+ (HUBComponentDefaults *)defaultsForTesting;

@end
