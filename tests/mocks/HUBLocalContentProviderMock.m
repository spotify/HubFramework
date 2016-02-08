#import "HUBLocalContentProviderMock.h"

@implementation HUBLocalContentProviderMock

@synthesize delegate = _delegate;

#pragma mark - HUBRemoteContentProvider

- (void)loadContentForViewWithURI:(NSURL *)viewURI
{
    [self loadContentOrReturnErrorForFallback:NO];
}

- (void)loadFallbackContentForViewWithURI:(NSURL *)viewURI forRemoteContentProviderError:(NSError *)error
{
    [self loadContentOrReturnErrorForFallback:YES];
}

#pragma mark - Private utilities

- (void)loadContentOrReturnErrorForFallback:(BOOL)forFallback
{
    if (self.error == nil) {
        NSAssert(self.contentLoadingBlock != nil, @"No content loading block or error set");
        self.contentLoadingBlock(forFallback);
        [self.delegate localContentProviderDidLoad:self];
    } else {
        [self.delegate localContentProvider:self didFailLoadingWithError:self.error];
    }
}

@end
