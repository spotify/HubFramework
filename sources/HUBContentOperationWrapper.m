#import "HUBContentOperationWrapper.h"

#import "HUBContentOperation.h"

@interface HUBContentOperationWrapper () <HUBContentOperationDelegate>

@property (nonatomic, strong, readonly) id<HUBContentOperation> contentOperation;
@property (nonatomic, assign) BOOL isExecuting;

@end

@implementation HUBContentOperationWrapper

#pragma mark - Initializer

- (instancetype)initWithContentOperation:(id<HUBContentOperation>)contentOperation index:(NSUInteger)index
{
    self = [super init];
    
    if (self) {
        _contentOperation = contentOperation;
        _contentOperation.delegate = self;
        _index = index;
    }
    
    return self;
}

#pragma mark - API

- (void)performOperationForViewURI:(NSURL *)viewURI
                 connectivityState:(HUBConnectivityState)connectivityState
                  viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                     previousError:(nullable NSError *)previousError
{
    self.isExecuting = YES;
    
    [self.contentOperation performForViewURI:viewURI
                           connectivityState:connectivityState
                            viewModelBuilder:viewModelBuilder
                               previousError:previousError];
}

#pragma mark - HUBContentOperationDelegate

- (void)contentOperationDidFinish:(id<HUBContentOperation>)operation
{
    [self finishWithError:nil];
}

- (void)contentOperation:(id<HUBContentOperation>)operation didFailWithError:(NSError *)error
{
    [self finishWithError:error];
}

- (void)contentOperationRequiresRescheduling:(id<HUBContentOperation>)operation
{
    [self.delegate contentOperationWrapperRequiresRescheduling:self];
}

#pragma mark - Private utilities

- (void)finishWithError:(nullable NSError *)error
{
    if (!self.isExecuting) {
        return;
    }
    
    self.isExecuting = NO;
    
    id<HUBContentOperationWrapperDelegate> const delegate = self.delegate;
    
    if (error == nil) {
        [delegate contentOperationWrapperDidFinish:self];
    } else {
        NSError * const nonNilError = error;
        [delegate contentOperationWrapper:self didFailWithError:nonNilError];
    }
}

@end
