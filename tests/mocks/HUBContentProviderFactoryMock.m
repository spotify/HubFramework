#import "HUBContentProviderFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBContentProviderFactoryMock

- (nullable id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI
{
    return self.remoteContentProvider;
}

- (nullable id<HUBLocalContentProvider>)createLocalContentProviderForViewURI:(NSURL *)viewURI
{
    return self.localContentProvider;
}

@end

NS_ASSUME_NONNULL_END
