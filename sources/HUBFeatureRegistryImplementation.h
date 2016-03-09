#import "HUBFeatureRegistry.h"

@protocol HUBDefaultRemoteContentProviderFactory;
@class HUBFeatureRegistration;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBFeatureRegistry` API
@interface HUBFeatureRegistryImplementation : NSObject <HUBFeatureRegistry>

/**
 *  Initialize an instance with a default remote content provider factory
 *
 *  @param defaultRemoteContentProviderFactory The default remote content provider factory to use for features using the
 *         `HUBRemoteContentURLResolver` API.
 */
- (instancetype)initWithDefaultRemoteContentProviderFactory:(id<HUBDefaultRemoteContentProviderFactory>)defaultRemoteContentProviderFactory NS_DESIGNATED_INITIALIZER;

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
