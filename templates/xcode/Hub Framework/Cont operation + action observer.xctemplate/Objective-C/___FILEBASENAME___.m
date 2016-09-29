#import "___FILEBASENAME___.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize delegate = _delegate;

- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    // Perform the content operation, and call the delegate once done
}

- (void)actionPerformedWithContext:(id<HUBActionContext>)context
                           viewURI:(NSURL *)viewURI
                       featureInfo:(id<HUBFeatureInfo>)featureInfo
                 connectivityState:(HUBConnectivityState)connectivityState
{
    // React to that an action was performed in the content operation's view
}

@end

NS_ASSUME_NONNULL_END
