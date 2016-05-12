#import "___FILEBASENAME___.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize delegate = _delegate;

- (void)addInitialContentForViewURI:(NSURL *)viewURI
                 toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    // Optionally add any initial, "skeleton" view content to display while loading
}

- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    // Perform the content operation, and call the delegate once done
}

@end

NS_ASSUME_NONNULL_END
