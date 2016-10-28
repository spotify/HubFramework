/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

#import "HUBViewModelLoaderImplementation.h"

#import "HUBFeatureInfo.h"
#import "HUBConnectivityStateResolver.h"
#import "HUBContentOperationWithInitialContent.h"
#import "HUBContentOperationActionObserver.h"
#import "HUBContentOperationActionPerformer.h"
#import "HUBActionPerformer.h"
#import "HUBContentReloadPolicy.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBContentOperationWrapper.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelLoaderImplementation () <HUBContentOperationWrapperDelegate, HUBConnectivityStateResolverObserver>

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
@property (nonatomic, strong, nullable) id<HUBViewModel> previouslyLoadedViewModel;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, HUBViewModelBuilderImplementation *> *builderSnapshots;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSError *> *errorSnapshots;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *currentBuilder;
@property (nonatomic, strong, nullable) NSError *currentError;

@end

@implementation HUBViewModelLoaderImplementation

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

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
        _builderSnapshots = [NSMutableDictionary new];
        _errorSnapshots = [NSMutableDictionary new];
        
        [connectivityStateResolver addObserver:self];
    }
    
    return self;
}

- (void)dealloc
{
    [_connectivityStateResolver removeObserver:self];
}

#pragma mark - Public API

- (void)actionPerformedWithContext:(id<HUBActionContext>)context
{
    for (id<HUBContentOperation> const operation in self.contentOperations) {
        if (![operation conformsToProtocol:@protocol(HUBContentOperationActionObserver)]) {
            continue;
        }
        
        [(id<HUBContentOperationActionObserver>)operation actionPerformedWithContext:context
                                                                         featureInfo:self.featureInfo
                                                                   connectivityState:self.connectivityState];
    }
}

#pragma mark - Accessor overrides

- (void)setActionPerformer:(nullable id<HUBActionPerformer>)actionPerformer
{
    _actionPerformer = actionPerformer;
    
    for (id<HUBContentOperation> const operation in self.contentOperations) {
        if (![operation conformsToProtocol:@protocol(HUBContentOperationActionPerformer)]) {
            continue;
        }
        
        ((id<HUBContentOperationActionPerformer>)operation).actionPerformer = actionPerformer;
    }
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
    
    [self scheduleContentOperationsFromIndex:0];
}

#pragma mark - HUBContentOperationWrapperDelegate

- (void)contentOperationWrapperDidFinish:(HUBContentOperationWrapper *)operationWrapper
{
    HUBPerformOnMainQueue(^{
        self.currentError = nil;
        [self performFirstContentOperationInQueueAfterFinishingOperation:operationWrapper];
    });
}

- (void)contentOperationWrapper:(HUBContentOperationWrapper *)operationWrapper didFailWithError:(NSError *)error
{
    HUBPerformOnMainQueue(^{
        self.currentError = error;
        [self performFirstContentOperationInQueueAfterFinishingOperation:operationWrapper];
    });
}

- (void)contentOperationWrapperRequiresRescheduling:(HUBContentOperationWrapper *)operationWrapper
{
    HUBPerformOnMainQueue(^{
        [self scheduleContentOperationsFromIndex:operationWrapper.index];
    });
}

#pragma mark - HUBConnectivityStateResolverObserver

- (void)connectivityStateResolverStateDidChange:(id<HUBConnectivityStateResolver>)resolver
{
    HUBConnectivityState previousConnectivityState = self.connectivityState;
    self.connectivityState = [self.connectivityStateResolver resolveConnectivityState];
    
    if (self.connectivityState != previousConnectivityState) {
        [self.delegate viewModelLoader:self didLoadViewModel:self.initialViewModel];
        [self scheduleContentOperationsFromIndex:0];
    }
}

#pragma mark - Private utilities

- (HUBViewModelBuilderImplementation *)builderForContentOperationAtIndex:(NSUInteger)index
                                             previouslyExecutedOperation:(nullable HUBContentOperationWrapper *)previouslyExecutedOperation
{
    if (index == 0) {
        return [self createBuilder];
    }
    
    if (previouslyExecutedOperation != nil) {
        if (previouslyExecutedOperation.index == index - 1) {
            NSAssert(self.currentBuilder != nil, @"Unexpected nil view model builder in ongoing content loading chain");
            self.builderSnapshots[@(index)] = [self.currentBuilder copy];
            self.errorSnapshots[@(index)] = self.currentError;
            
            HUBViewModelBuilderImplementation * const copiedBuilder = [self.currentBuilder copy];
            return copiedBuilder;
        }
    }
    
    HUBViewModelBuilderImplementation * const existingSnapshot = self.builderSnapshots[@(index)];
    NSAssert(existingSnapshot != nil, @"Unexpected nil shapshot for content operation at index: %lu", (unsigned long)index);
    return [existingSnapshot copy];
}
                                             
- (HUBViewModelBuilderImplementation *)createBuilder
{
    return [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                       componentDefaults:self.componentDefaults
                                                       iconImageResolver:self.iconImageResolver];
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
        [self performFirstContentOperationInQueueAfterFinishingOperation:nil];
    }
}

- (void)performFirstContentOperationInQueueAfterFinishingOperation:(nullable HUBContentOperationWrapper *)finishedOperation
{
    if (self.contentOperationQueue.count == 0) {
        [self contentOperationQueueDidBecomeEmpty];
        return;
    }
    
    HUBContentOperationWrapper * const operation = self.contentOperationQueue[0];
    [self.contentOperationQueue removeObjectAtIndex:0];
    
    HUBViewModelBuilderImplementation * const builder = [self builderForContentOperationAtIndex:operation.index
                                                                    previouslyExecutedOperation:finishedOperation];
    
    self.currentBuilder = builder;
    
    NSError * const previousError = self.errorSnapshots[@(operation.index)];
    
    [operation performOperationForViewURI:self.viewURI
                              featureInfo:self.featureInfo
                        connectivityState:self.connectivityState
                         viewModelBuilder:builder
                            previousError:previousError];
}

- (void)contentOperationQueueDidBecomeEmpty
{
    id<HUBViewModelLoaderDelegate> const delegate = self.delegate;
    
    if (self.currentError != nil) {
        NSError * const error = self.currentError;
        [delegate viewModelLoader:self didFailLoadingWithError:error];
        self.currentError = nil;
        return;
    }
    
    if (!self.currentBuilder.headerComponentModelBuilderExists && self.currentBuilder.navigationBarTitle == nil) {
        self.currentBuilder.navigationBarTitle = self.featureInfo.title;
    }
    
    id<HUBViewModel> const viewModel = [self.currentBuilder build];
    self.previouslyLoadedViewModel = viewModel;
    [delegate viewModelLoader:self didLoadViewModel:viewModel];
}

@end

NS_ASSUME_NONNULL_END
