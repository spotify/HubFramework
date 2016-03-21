#import "HUBRemoteContentURLResolver.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked remote content URL resolver, for use in tests only
@interface HUBRemoteContentURLResolverMock : NSObject <HUBRemoteContentURLResolver>

/// The content URL that the resolver is always resolving
@property (nonatomic, copy, nullable) NSURL *contentURL;

/// The view URIs that the URL resolver has been asked to resolve URLs for
@property (nonatomic, strong, readonly) NSSet<NSURL *> *viewURIs;

@end

NS_ASSUME_NONNULL_END
