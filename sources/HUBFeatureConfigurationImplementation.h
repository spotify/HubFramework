#import "HUBFeatureConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBFeatureConfiguration` API
@interface HUBFeatureConfigurationImplementation : NSObject <HUBFeatureConfiguration>

/**
 *  Initialize an instance of this class with its required values
 *
 *  @param rootViewURI The root view URI that the configuration object should have
 *  @param contentProviderFactory The content provider factory that should be associated with the configuration object
 */
- (instancetype)initWithRootViewURI:(NSURL *)rootViewURI
             contentProviderFactory:(id<HUBContentProviderFactory>)contentProviderFactory NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
