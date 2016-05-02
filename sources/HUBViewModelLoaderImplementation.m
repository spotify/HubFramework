#import "HUBViewModelLoaderImplementation.h"

#import "HUBConnectivityStateResolver.h"
#import "HUBContentOperation.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderImplementation () <HUBContentOperationDelegate>

@property (nonatomic, copy, readonly) NSURL *viewURI;
@property (nonatomic, copy, readonly) NSString *featureIdentifier;
@property (nonatomic, copy, readonly) NSArray<id<HUBContentOperation>> *contentOperations;
@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable) id<HUBViewModel> cachedInitialViewModel;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *builder;
@property (nonatomic, assign) NSUInteger currentlyLoadingContentOperationIndex;
@property (nonatomic, strong, nullable) NSError *encounteredError;

@end

@implementation HUBViewModelLoaderImplementation

@synthesize delegate = _delegate;

#pragma mark - Public API

- (instancetype)initWithViewURI:(NSURL *)viewURI
              featureIdentifier:(NSString *)featureIdentifier
              contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
              componentDefaults:(HUBComponentDefaults *)componentDefaults
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
              iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
               initialViewModel:(nullable id<HUBViewModel>)initialViewModel
{
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(contentOperations.count > 0);
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    NSParameterAssert(iconImageResolver != nil);
    NSParameterAssert(connectivityStateResolver != nil);
    
    self = [super init];
    
    if (self) {
        _viewURI = [viewURI copy];
        _featureIdentifier = [featureIdentifier copy];
        _contentOperations = [contentOperations copy];
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _connectivityStateResolver = connectivityStateResolver;
        _iconImageResolver = iconImageResolver;
        _cachedInitialViewModel = initialViewModel;
        _currentlyLoadingContentOperationIndex = NSNotFound;

        for (id<HUBContentOperation> const operation in _contentOperations) {
            operation.delegate = self;
        }
    }
    
    return self;
}

#pragma mark - HUBViewModelLoader

- (nullable id<HUBViewModel>)initialViewModel
{
    id<HUBViewModel> const cachedInitialViewModel = self.cachedInitialViewModel;
    
    if (cachedInitialViewModel != nil) {
        return cachedInitialViewModel;
    }
    
    HUBViewModelBuilderImplementation * const builder = [self createBuilder];
    
    for (id<HUBContentOperation> const operation in self.contentOperations) {
        [operation addInitialContentForViewURI:self.viewURI toViewModelBuilder:builder];
    }
    
    id<HUBViewModel> const initialViewModel = [builder build];
    self.cachedInitialViewModel = initialViewModel;
    return initialViewModel;
}

- (void)loadViewModel
{
    self.builder = nil;
    self.currentlyLoadingContentOperationIndex = 0;
    [self loadNextContentOperationInQueue];
}

#pragma mark - HUBContentOperationDelegate

- (void)contentOperationDidFinish:(id<HUBContentOperation>)operation
{
    [self handleFinishedContentOperation:operation mode:HUBContentOperationModeAsynchronous error:nil];
}

- (void)contentOperation:(id<HUBContentOperation>)operation didFailWithError:(NSError *)error
{
    [self handleFinishedContentOperation:operation mode:HUBContentOperationModeAsynchronous error:error];
}

#pragma mark - Private utilities

- (HUBViewModelBuilderImplementation *)getOrCreateBuilder
{
    if (self.builder == nil) {
        self.builder = [self createBuilder];
    }
    
    HUBViewModelBuilderImplementation * const builder = self.builder;
    return builder;
}
                                             
- (HUBViewModelBuilderImplementation *)createBuilder
{
    return [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                     JSONSchema:self.JSONSchema
                                                              componentDefaults:self.componentDefaults
                                                              iconImageResolver:self.iconImageResolver];
}

- (nullable id<HUBContentOperation>)currentlyLoadingContentOperation
{
    if (self.currentlyLoadingContentOperationIndex >= self.contentOperations.count) {
        return nil;
    }
    
    return self.contentOperations[self.currentlyLoadingContentOperationIndex];
}

- (void)loadNextContentOperationInQueue
{
    id<HUBContentOperation> const contentOperation = [self currentlyLoadingContentOperation];

    if (contentOperation == nil) {
        [self allContentOperationsDidFinish];
        return;
    }
    
    HUBConnectivityState const connectivityState = [self.connectivityStateResolver resolveConnectivityState];
    id<HUBViewModelBuilder> const builder = [self getOrCreateBuilder];
    
    HUBContentOperationMode const contentOperationMode = [contentOperation loadContentForViewURI:self.viewURI
                                                                                connectivityState:connectivityState
                                                                                viewModelBuilder:builder
                                                                   previousContentOperationError:self.encounteredError];
    
    switch (contentOperationMode) {
        case HUBContentOperationModeNone:
        case HUBContentOperationModeSynchronous:
            if (self.currentlyLoadingContentOperation == contentOperation) {
                // This means the operation hasn't been handled synchronously from within the loadMethod above
                [self handleFinishedContentOperation:contentOperation mode:contentOperationMode error:nil];
            }
            break;
        case HUBContentOperationModeAsynchronous:
            break;
    }
}

- (void)handleFinishedContentOperation:(id<HUBContentOperation>)operation mode:(HUBContentOperationMode)mode error:(nullable NSError *)error
{
    if (mode != HUBContentOperationModeNone) {
        self.encounteredError = error;
    }
    
    if ([self currentlyLoadingContentOperation] != operation) {
        // Not the one we expected;

        if ([self currentlyLoadingContentOperation] == nil && error != nil) {
            // We finished processing the chain, so errors shouldn't retrigger reloads
            return;
        }

        NSUInteger operationIndex = [self.contentOperations indexOfObject:operation];

        if (operationIndex > self.currentlyLoadingContentOperationIndex) {
            // Content operation in the future, this is probably an out of sync operation from a previous reload;
            // Ignore it (we'll reload it anyway if needed)
            return;
        } else {
            // Previous content operation, must reset the chain starting at this point
            self.currentlyLoadingContentOperationIndex = operationIndex;
        }
    }
    
    self.currentlyLoadingContentOperationIndex++;
    [self loadNextContentOperationInQueue];
}

- (void)allContentOperationsDidFinish
{
    id<HUBViewModelLoaderDelegate> const delegate = self.delegate;
    
    if (delegate == nil) {
        return;
    }
    
    if (self.encounteredError == nil) {
        if (self.builder == nil) {
            return;
        }
        
        id<HUBViewModel> const viewModel = [self.builder build];
        [delegate viewModelLoader:self didLoadViewModel:viewModel];
    } else {
        NSError * const error = self.encounteredError;
        [delegate viewModelLoader:self didFailLoadingWithError:error];
    }
}

@end

NS_ASSUME_NONNULL_END
