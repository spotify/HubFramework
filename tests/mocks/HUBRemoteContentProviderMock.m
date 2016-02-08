#import "HUBRemoteContentProviderMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBRemoteContentProviderMock ()

@property (nonatomic, readwrite) BOOL called;

@end

@implementation HUBRemoteContentProviderMock

@synthesize delegate = _delegate;

#pragma mark - HUBRemoteContentProvider

- (void)loadContentForViewWithURI:(NSURL *)viewURI
{
    [self loadContentOrReturnError];
}

- (void)loadContentFromURL:(NSURL *)contentURL
{
    [self loadContentOrReturnError];
}

#pragma mark - Private utilities

- (void)loadContentOrReturnError
{
    self.called = YES;
    
    id<HUBRemoteContentProviderDelegate> const delegate = self.delegate;
    
    if (self.error == nil) {
        NSAssert(self.data != nil, @"No data or error set");
        NSData * const data = self.data;
        [delegate remoteContentProvider:self didLoadJSONData:data];
    } else {
        NSError * const error = self.error;
        [delegate remoteContentProvider:self didFailLoadingWithError:error];
    }
}

@end

NS_ASSUME_NONNULL_END
