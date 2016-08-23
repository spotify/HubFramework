#import "HUBViewModelLoaderImplementation.h"

#import "HUBFeatureInfo.h"
#import "HUBConnectivityStateResolver.h"
#import "HUBContentOperationWithInitialContent.h"
#import "HUBContentReloadPolicy.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBContentOperationWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderImplementation () <HUBContentOperationWrapperDelegate, HUBConnectivityStateResolverObserver, HUBModificationDelegate>

@property (nonatomic, copy, readonly) NSURL *viewURI;
@property (nonatomic, strong, readonly) id<HUBFeatureInfo> featureInfo;
@property (nonatomic, copy, readonly) NSArray<id<HUBContentOperation>> *contentOperations;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, HUBContentOperationWrapper *> *contentOperationWrappers;
@property (nonatomic, strong, readonly) NSMutableArray<HUBContentOperationWrapper *> *contentOperationQueue;
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;
@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, assign) HUBConnectivityState connectivityState;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable) id<HUBViewModel> cachedInitialViewModel;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *builder;
@property (nonatomic) BOOL builderModified;
@property (nonatomic, strong, nullable) id<HUBViewModel> previouslyLoadedViewModel;
@property (nonatomic, strong, nullable) NSError *encounteredError;

@end

@implementation HUBViewModelLoaderImplementation

@synthesize delegate = _delegate;

#pragma mark - Public API

- (instancetype)initWithViewURI:(NSURL *)viewURI
                    featureInfo:(id<HUBFeatureInfo>)featureInfo
              contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
            contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
                     JSONSchema:(id<HUBJSONSchema>)JSONSchema
              componentDefaults:(HUBComponentDefaults *)componentDefaults
      connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
              iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
               initialViewModel:(nullable id<HUBViewModel>)initialViewModel
{
    NSParameterAssert(viewURI != nil);
    NSParameterAssert(featureInfo != nil);
    NSParameterAssert(contentOperations.count > 0);
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    NSParameterAssert(connectivityStateResolver != nil);
    
    self = [super init];
    
    if (self) {
        _viewURI = [viewURI copy];
        _featureInfo = featureInfo;
        _contentOperations = [contentOperations copy];
        _contentOperationWrappers = [NSMutableDictionary new];
        _contentOperationQueue = [NSMutableArray new];
        _contentReloadPolicy = contentReloadPolicy;
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _connectivityStateResolver = connectivityStateResolver;
        _connectivityState = [_connectivityStateResolver resolveConnectivityState];
        _iconImageResolver = iconImageResolver;
        _cachedInitialViewModel = initialViewModel;
        
        [connectivityStateResolver addObserver:self];
    }
    
    return self;
}

- (void)dealloc
{
    [_connectivityStateResolver removeObserver:self];
}

#pragma mark - HUBViewModelLoader

- (id<HUBViewModel>)initialViewModel
{
    id<HUBViewModel> const cachedInitialViewModel = self.cachedInitialViewModel;
    
    if (cachedInitialViewModel != nil) {
        return cachedInitialViewModel;
    }
    
    HUBViewModelBuilderImplementation * const builder = [self createBuilder];
    
    for (id<HUBContentOperation> const operation in self.contentOperations) {
        if ([operation conformsToProtocol:@protocol(HUBContentOperationWithInitialContent)]) {
            id<HUBContentOperationWithInitialContent> const initialContentOperation = (id<HUBContentOperationWithInitialContent>)operation;
            [initialContentOperation addInitialContentForViewURI:self.viewURI toViewModelBuilder:builder];
        }
    }
    
    id<HUBViewModel> const initialViewModel = [builder build];
    self.cachedInitialViewModel = initialViewModel;
    return initialViewModel;
}

- (void)loadViewModel
{
    if (self.contentReloadPolicy != nil) {
        if (self.previouslyLoadedViewModel != nil) {
            id<HUBViewModel> const previouslyLoadedViewModel = self.previouslyLoadedViewModel;
            
            if (![self.contentReloadPolicy shouldReloadContentForViewURI:self.viewURI currentViewModel:previouslyLoadedViewModel]) {
                return;
            }
        }
    }
    
    [self performViewModelLoading];
}

#pragma mark - HUBContentOperationWrapperDelegate

- (void)contentOperationWrapperDidFinish:(HUBContentOperationWrapper *)operationWrapper
{
    self.encounteredError = nil;
    [self performFirstContentOperationInQueue];
}

- (void)contentOperationWrapper:(HUBContentOperationWrapper *)operationWrapper didFailWithError:(NSError *)error
{
    self.encounteredError = error;
    [self performFirstContentOperationInQueue];
}

- (void)contentOperationWrapperRequiresRescheduling:(HUBContentOperationWrapper *)operationWrapper
{
    [self scheduleContentOperationsFromIndex:operationWrapper.index];
}

#pragma mark - HUBConnectivityStateResolverObserver

- (void)connectivityStateResolverStateDidChange:(id<HUBConnectivityStateResolver>)resolver
{
    HUBConnectivityState previousConnectivityState = self.connectivityState;
    self.connectivityState = [self.connectivityStateResolver resolveConnectivityState];
    
    if (self.connectivityState != previousConnectivityState) {
        [self.delegate viewModelLoader:self didLoadViewModel:self.initialViewModel];
        [self performViewModelLoading];
    }
}

#pragma mark - HUBModificationDelegate

- (void)modifiableWasModified:(id<HUBModifiable>)modifiable
{
    self.builderModified = YES;
}

#pragma mark - Private utilities

- (void)performViewModelLoading
{
    self.builder = nil;
    self.encounteredError = nil;
    
    [self.contentOperationWrappers removeAllObjects];
    [self scheduleContentOperationsFromIndex:0];
}

- (HUBViewModelBuilderImplementation *)createOrCopyBuilder
{
    HUBViewModelBuilderImplementation * const existingBuilder = self.builder;
    
    if (existingBuilder != nil) {
        HUBViewModelBuilderImplementation * const copiedBuilder = [existingBuilder copy];
        copiedBuilder.modificationDelegate = self;
        existingBuilder.modificationDelegate = nil;
        return copiedBuilder;
    }
    
    HUBViewModelBuilderImplementation * const newBuilder = [self createBuilder];
    newBuilder.modificationDelegate = self;
    return newBuilder;
}
                                             
- (HUBViewModelBuilderImplementation *)createBuilder
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureInfo.identifier
                                                                                                                  JSONSchema:self.JSONSchema
                                                                                                           componentDefaults:self.componentDefaults
                                                                                                           iconImageResolver:self.iconImageResolver];
    
    builder.modificationDelegate = self;
    return builder;
}

- (void)scheduleContentOperationsFromIndex:(NSUInteger)startIndex
{    
    NSParameterAssert(startIndex < self.contentOperations.count);
    
    NSMutableArray<HUBContentOperationWrapper *> * const operations = [NSMutableArray new];
    NSUInteger operationIndex = startIndex;
    
    while (operationIndex < self.contentOperations.count) {
        HUBContentOperationWrapper * const cachedOperationWrapper = self.contentOperationWrappers[@(operationIndex)];
        
        if (cachedOperationWrapper != nil) {
            [operations addObject:cachedOperationWrapper];
        } else {
            id<HUBContentOperation> const operation = self.contentOperations[operationIndex];
            HUBContentOperationWrapper * const operationWrapper = [[HUBContentOperationWrapper alloc] initWithContentOperation:operation index:operationIndex];
            operationWrapper.delegate = self;
            [operations addObject:operationWrapper];
            self.contentOperationWrappers[@(operationIndex)] = operationWrapper;
        }
        
        operationIndex++;
    }
    
    BOOL const shouldRestartQueue = (self.contentOperationQueue.count == 0);
    [self.contentOperationQueue addObjectsFromArray:operations];
    
    if (shouldRestartQueue) {
        [self performFirstContentOperationInQueue];
    }
}

- (void)performFirstContentOperationInQueue
{
    if (self.contentOperationQueue.count == 0) {
        [self contentOperationQueueDidBecomeEmpty];
        return;
    }
    
    HUBContentOperationWrapper * const operation = self.contentOperationQueue[0];
    [self.contentOperationQueue removeObjectAtIndex:0];
    
    HUBViewModelBuilderImplementation * const builder = [self createOrCopyBuilder];
    self.builder = builder;
    
    [operation performOperationForViewURI:self.viewURI
                              featureInfo:self.featureInfo
                        connectivityState:self.connectivityState
                         viewModelBuilder:builder
                            previousError:self.encounteredError];
}

- (void)contentOperationQueueDidBecomeEmpty
{
    id<HUBViewModelLoaderDelegate> const delegate = self.delegate;
    
    if (self.encounteredError != nil) {
        NSError * const error = self.encounteredError;
        [delegate viewModelLoader:self didFailLoadingWithError:error];
        self.encounteredError = nil;
        return;
    }
    
    if (!self.builder.headerComponentModelBuilderExists && self.builder.navigationBarTitle == nil) {
        self.builder.navigationBarTitle = self.featureInfo.title;
    }
    
    if (!self.builderModified) {
        id<HUBViewModel> const previouslyLoadedViewModel = self.previouslyLoadedViewModel;
        
        if (previouslyLoadedViewModel != nil) {
            [delegate viewModelLoader:self didLoadViewModel:previouslyLoadedViewModel];
            return;
        }
    }
    
    id<HUBViewModel> const viewModel = [self.builder build];
    self.previouslyLoadedViewModel = viewModel;
    self.builderModified = NO;
    
    [delegate viewModelLoader:self didLoadViewModel:viewModel];
}

@end

NS_ASSUME_NONNULL_END
