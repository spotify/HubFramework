#import "HUBContentOperationMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentOperationMock ()

@property (nonatomic, assign, readwrite) NSUInteger performCount;
@property (nonatomic, strong, readwrite) id<HUBFeatureInfo> featureInfo;
@property (nonatomic, assign, readwrite) HUBConnectivityState connectivityState;
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

- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    self.performCount++;
    self.featureInfo = featureInfo;
    self.connectivityState = connectivityState;
    self.previousContentOperationError = previousError;
    
    id<HUBContentOperationDelegate> const delegate = self.delegate;
    
    if (self.error != nil) {
        NSError * const error = self.error;
        [delegate contentOperation:self didFailWithError:error];
    } else if (self.contentLoadingBlock != nil) {
        BOOL const shouldCallDelegate = self.contentLoadingBlock(viewModelBuilder);
        
        if (shouldCallDelegate) {
            [delegate contentOperationDidFinish:self];
        }
    } else {
        [delegate contentOperationDidFinish:self];
    }
}

@end

NS_ASSUME_NONNULL_END
