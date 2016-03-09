#import "HUBRemoteContentProviderFactory.h"

@protocol HUBDefaultRemoteContentProviderFactory;
@protocol HUBRemoteContentURLResolver;

NS_ASSUME_NONNULL_BEGIN

/// Wrapper class that enables a `HUBDefaultRemoteContentProviderFactory` to be used by the Hub Framework
@interface HUBDefaultRemoteContentProviderFactoryWrapper : NSObject <HUBRemoteContentProviderFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param defaultRemoteContentProviderFactory The default remote content provider factory to wrap
 *  @param URLResolver The URL resolver to pass to the default remote content provider factory
 *  @param featureIdentifier The identifier for the feature that this content provider factory is for
 */
- (instancetype)initWithDefaultRemoteContentProviderFactory:(id<HUBDefaultRemoteContentProviderFactory>)defaultRemoteContentProviderFactory
                                                URLResolver:(id<HUBRemoteContentURLResolver>)URLResolver
                                          featureIdentifier:(NSString *)featureIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
