#import "___FILEBASENAME___.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize delegate = _delegate;

- (void)addInitialContentForViewURI:(NSURL *)viewURI
                 toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    // Optionally add any initial, "skeleton" view content to display while loading
}

- (HUBContentProviderMode)loadContentForViewURI:(NSURL *)viewURI
                              connectivityState:(HUBConnectivityState)connectivityState
                               viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                   previousContentProviderError:(nullable NSError *)previousContentProviderError
{
    // Load the view's content here, returning the mode that the content provider uses
    return HUBContentProviderModeNone;
}

- (HUBContentProviderMode)loadContentFromExtensionURL:(NSURL *)extensionURL
                                           forViewURI:(NSURL *)viewURI
                                     viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    // Optionally extend the current view model with data from the given `extensionURL`
    return HUBContentProviderModeNone;
}

@end

NS_ASSUME_NONNULL_END
