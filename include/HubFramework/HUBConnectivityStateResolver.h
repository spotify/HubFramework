#import "HUBConnectivityState.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that can resolve an application's current connectivity state
 *
 *  You conform to this protocol in a custom object and supply it when setting up your application's
 *  `HUBManager`. The Hub Framework uses the information provided by its connectivity state resolver
 *  to determine whether remote content should be loaded or not at a given time.
 */
@protocol HUBConnectivityStateResolver <NSObject>

/**
 *  Resolve the current connectivity state of the application
 *
 *  The Hub Framework will call this method on your connectivity state resolver every time it's about
 *  to load content. If `HUBConnectivityStateOffline` is returned, no remote content will be loaded.
 */
- (HUBConnectivityState)resolveConnectivityState;

@end

NS_ASSUME_NONNULL_END
