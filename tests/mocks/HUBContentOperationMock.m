#import "HUBContentOperationMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentOperationMock ()

@property (nonatomic, assign, readwrite) NSUInteger performCount;
@property (nonatomic, strong, readwrite, nullable) NSError *previousContentOperationError;
@property (nonatomic, assign, readwrite) HUBConnectivityState connectivityState;

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
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    self.connectivityState = connectivityState;
    self.performCount++;
    self.previousContentOperationError = previousError;
    
    id<HUBContentOperationDelegate> const delegate = self.delegate;
    
    if (self.contentLoadingBlock != nil) {
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
