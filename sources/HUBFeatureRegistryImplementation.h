#import "HUBFeatureRegistry.h"

@protocol HUBDataLoaderFactory;
@class HUBFeatureRegistration;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBFeatureRegistry` API
@interface HUBFeatureRegistryImplementation : NSObject <HUBFeatureRegistry>

/**
 *  Initialize an instance with a data loader factory
 *
 *  @param dataLoaderFactory The factory to use to create data loaders for features
 *         using `HUBRemoteContentURLResolver`.
 */
- (instancetype)initWithDataLoaderFactory:(id<HUBDataLoaderFactory>)dataLoaderFactory NS_DESIGNATED_INITIALIZER;

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

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
