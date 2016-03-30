#import "HUBContentProviderMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentProviderMock ()

@property (nonatomic, strong, readwrite, nullable) NSError *previousContentProviderError;

@end

@implementation HUBContentProviderMock

@synthesize delegate = _delegate;

#pragma mark - HUBContentProvider

- (void)addInitialContentForViewURI:(NSURL *)viewURI toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    if (self.initialContentLoadingBlock != nil) {
        self.initialContentLoadingBlock(viewModelBuilder);
    }
}

- (HUBContentProviderMode)loadContentForViewURI:(NSURL *)viewURI
                              connectivityState:(HUBConnectivityState)connectivityState
                               viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                   previousContentProviderError:(nullable NSError *)previousContentProviderError
{
    self.previousContentProviderError = previousContentProviderError;
    
    if (self.contentLoadingBlock != nil) {
        return self.contentLoadingBlock(viewModelBuilder);
    }
    
    return HUBContentProviderModeNone;
}

- (HUBContentProviderMode)loadContentFromExtensionURL:(NSURL *)extensionURL
                                           forViewURI:(NSURL *)viewURI
                                     viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    if (self.extensionContentLoadingBlock != nil) {
        return self.extensionContentLoadingBlock(viewModelBuilder);
    }
    
    return HUBContentProviderModeNone;
}

@end

NS_ASSUME_NONNULL_END
