#import "HUBRemoteContentProvider.h"

@protocol HUBRemoteContentURLResolver;
@protocol HUBDataLoader;

NS_ASSUME_NONNULL_BEGIN

/// Remote content provider that uses a `HUBRemoteContentURLResolver` and `HUBDataLoader` to load content
@interface HUBRemoteContentURLResolverContentProvider : NSObject <HUBRemoteContentProvider>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param URLResolver The object to use to resolve HTTP URLs from view URIs
 *  @param dataLoader The data loader to use to download binary data
 */
- (instancetype)initWithURLResolver:(id<HUBRemoteContentURLResolver>)URLResolver
                         dataLoader:(id<HUBDataLoader>)dataLoader NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
