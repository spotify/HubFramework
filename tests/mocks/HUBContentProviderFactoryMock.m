#import "HUBContentProviderFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBContentProviderFactoryMock

- (nullable id<HUBLocalContentProvider>)createLocalContentProviderForViewURI:(NSURL *)viewURI
{
    return nil;
}

- (nullable id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI
{
    return nil;
}

@end

NS_ASSUME_NONNULL_END
