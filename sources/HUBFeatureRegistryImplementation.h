#import "HUBFeatureRegistry.h"

@class HUBFeatureRegistration;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBFeatureRegistry` API
@interface HUBFeatureRegistryImplementation : NSObject <HUBFeatureRegistry>

/**
 *  Return the feature registration associated with a certain view URI
 *
 *  @param viewURI The view URI to retrieve a feature registration for
 *
 *  The registry will look for a registration that has a view URI predicate that matches the given view URI.
 */
- (nullable HUBFeatureRegistration *)featureRegistrationForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
