#import "HUBContentProviderFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBContentProviderFactoryMock

- (id<HUBRemoteContentProvider>)createRemoteContentProviderForViewURI:(NSURL *)viewURI
                                                    featureIdentifier:(NSString *)featureIdentifier
                                             remoteContentURLResolver:(id<HUBRemoteContentURLResolver>)remoteContentURLResolver
{
    id<HUBRemoteContentProvider> const remoteContentProvider = [self createRemoteContentProviderForViewURI:viewURI];
    
    NSAssert(remoteContentProvider != nil,
             @"When used as a default remote content provider, HUBContentProviderFactoryMock must return a content provider");
    
    return remoteContentProvider;
}

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
