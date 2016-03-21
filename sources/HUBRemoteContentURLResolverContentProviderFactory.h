#import "HUBRemoteContentProviderFactory.h"

@protocol HUBRemoteContentURLResolver;
@protocol HUBDataLoaderFactory;

NS_ASSUME_NONNULL_BEGIN

/// Factory that creates remote content providers that are based on a `HUBRemoteContentURLResolver`
@interface HUBRemoteContentURLResolverContentProviderFactory : NSObject <HUBRemoteContentProviderFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param URLResolver The object to use to resolve HTTP URLs from view URIs
 *  @param featureIdentifier The identifier of the feature that will be this content provider factory
 *  @param dataLoaderFactory The factory to use to create data loaders
 */
- (instancetype)initWithURLResolver:(id<HUBRemoteContentURLResolver>)URLResolver
                  featureIdentifier:(NSString *)featureIdentifier
                  dataLoaderFactory:(id<HUBDataLoaderFactory>)dataLoaderFactory NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
