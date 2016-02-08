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
    
    if (self.error == nil) {
        NSAssert(self.data != nil, @"No data or error set");
        [self.delegate remoteContentProvider:self didLoadJSONData:self.data];
    } else {
        [self.delegate remoteContentProvider:self didFailLoadingWithError:self.error];
    }
}

@end

NS_ASSUME_NONNULL_END
