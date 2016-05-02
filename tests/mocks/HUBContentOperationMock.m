#import "HUBContentOperationMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentOperationMock ()

@property (nonatomic, strong, readwrite, nullable) NSError *previousContentOperationError;

@end

@implementation HUBContentOperationMock

@synthesize delegate = _delegate;

#pragma mark - HUBContentOperation

- (void)addInitialContentForViewURI:(NSURL *)viewURI toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    if (self.initialContentLoadingBlock != nil) {
        self.initialContentLoadingBlock(viewModelBuilder);
    }
}

- (HUBContentOperationMode)loadContentForViewURI:(NSURL *)viewURI
                              connectivityState:(HUBConnectivityState)connectivityState
                               viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                    previousContentOperationError:(nullable NSError *)previousContentOperationError
{
    self.previousContentOperationError = previousContentOperationError;
    
    if (self.contentLoadingBlock != nil) {
        return self.contentLoadingBlock(viewModelBuilder);
    }
    
    return HUBContentOperationModeNone;
}

- (HUBContentOperationMode)loadContentFromExtensionURL:(NSURL *)extensionURL
                                           forViewURI:(NSURL *)viewURI
                                     viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    if (self.extensionContentLoadingBlock != nil) {
        return self.extensionContentLoadingBlock(viewModelBuilder);
    }
    
    return HUBContentOperationModeNone;
}

@end

NS_ASSUME_NONNULL_END
