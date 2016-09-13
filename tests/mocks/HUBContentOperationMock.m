#import "HUBContentOperationMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentOperationMock ()

@property (nonatomic, assign, readwrite) NSUInteger performCount;
@property (nonatomic, strong, readwrite) id<HUBFeatureInfo> featureInfo;
@property (nonatomic, assign, readwrite) HUBConnectivityState connectivityState;
@property (nonatomic, strong, readwrite, nullable) NSError *previousContentOperationError;
@property (nonatomic, strong, readwrite, nullable) id<HUBActionContext> actionContext;

@end

@implementation HUBContentOperationMock

@synthesize delegate = _delegate;

#pragma mark - HUBContentOperation

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

#pragma mark - HUBContentOperationWithInitialContent

- (void)addInitialContentForViewURI:(NSURL *)viewURI toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
{
    if (self.initialContentLoadingBlock != nil) {
        self.initialContentLoadingBlock(viewModelBuilder);
    }
}

#pragma mark - HUBContentOperationActionObserver

- (void)actionPerformedWithContext:(id<HUBActionContext>)context
                           viewURI:(NSURL *)viewURI
                       featureInfo:(id<HUBFeatureInfo>)featureInfo
                 connectivityState:(HUBConnectivityState)connectivityState
{
    self.actionContext = context;
}

#pragma mark - NSObject

- (BOOL)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == @protocol(HUBContentOperationWithInitialContent)) {
        return (self.initialContentLoadingBlock != nil);
    }
    
    return [super conformsToProtocol:protocol];
}

@end

NS_ASSUME_NONNULL_END
