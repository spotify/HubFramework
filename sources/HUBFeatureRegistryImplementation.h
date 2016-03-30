#import "HUBFeatureRegistry.h"

@protocol HUBDataLoaderFactory;
@class HUBFeatureRegistration;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBFeatureRegistry` API
@interface HUBFeatureRegistryImplementation : NSObject <HUBFeatureRegistry>

/**
 *  Return the feature registration associated with a certain view URI
 *
 *  @param viewURI The view URI to retrieve a feature registration for
 *
 *  The registry will look for a registration that has a `rootViewURI` which is a prefix
 *  of the supplied view URI. It will then check so that the feature's `viewURIQualifier`
 *  (if any) doesn't want to disqualify the view URI before returning the registration.
 */
- (nullable HUBFeatureRegistration *)featureRegistrationForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
