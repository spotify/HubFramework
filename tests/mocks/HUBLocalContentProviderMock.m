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
    id<HUBLocalContentProviderDelegate> const delegate = self.delegate;
    
    if (self.error == nil) {
        NSAssert(self.contentLoadingBlock != nil, @"No content loading block or error set");
        self.contentLoadingBlock(forFallback);
        [delegate localContentProviderDidLoad:self];
    } else {
        NSError * const error = self.error;
        [delegate localContentProvider:self didFailLoadingWithError:error];
    }
}

@end
