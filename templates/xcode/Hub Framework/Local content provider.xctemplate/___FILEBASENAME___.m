#import "___FILEBASENAME___.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize delegate = _delegate;

- (void)loadContentForViewWithURI:(NSURL *)viewURI
{
    /*
    *   1. Load local content from whichever source you want
    *   2. Retrieve a HUBViewModelBuilder from the delegate
    *   3. Add your content to the builder
    *   4. Call the delegate with a success/failure outcome
    */
}

- (void)loadFallbackContentForViewWithURI:(NSURL *)viewURI forRemoteContentProviderError:(NSError *)error
{
    // Load fallback content to be used in case a remote content provider encountered an error
}

@end

NS_ASSUME_NONNULL_END
