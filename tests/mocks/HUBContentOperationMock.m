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

#import "HUBContentOperationMock.h"
#import "HUBContentOperationContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBContentOperationMock ()

@property (nonatomic, assign, readwrite) NSUInteger performCount;
@property (nonatomic, strong, readwrite) id<HUBContentOperationContext> context;
@property (nonatomic, strong, readwrite, nullable) id<HUBActionContext> actionContext;

@end

@implementation HUBContentOperationMock

@synthesize delegate = _delegate;
@synthesize actionPerformer = _actionPerformer;

- (id<HUBFeatureInfo>)featureInfo
{
    return self.context.featureInfo;
}

- (HUBConnectivityState)connectivityState
{
    return self.context.connectivityState;
}

- (nullable NSError *)previousContentOperationError
{
    return self.context.previousError;
}

#pragma mark - HUBContentOperation

- (void)performInContext:(id<HUBContentOperationContext>)context
{
    self.performCount++;
    self.context = context;
    
    id<HUBContentOperationDelegate> const delegate = self.delegate;
    
    if (self.error != nil) {
        NSError * const error = self.error;
        [delegate contentOperation:self didFailWithError:error];
    } else if (self.contentLoadingBlock != nil) {
        BOOL const shouldCallDelegate = self.contentLoadingBlock(context.viewModelBuilder);
        
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

#pragma mark - HUBContentOperationWithPaginatedContent

- (void)appendContentForPageIndex:(NSUInteger)pageIndex inContext:(nonnull id<HUBContentOperationContext>)context
{
    self.context = context;
    
    id<HUBContentOperationDelegate> const delegate = self.delegate;
    
    if (self.error != nil) {
        NSError * const error = self.error;
        [delegate contentOperation:self didFailWithError:error];
        return;
    }

    BOOL const shouldCallDelegate = self.paginatedContentLoadingBlock(context.viewModelBuilder, pageIndex);
    
    if (shouldCallDelegate) {
        [delegate contentOperationDidFinish:self];
    }
}

#pragma mark - HUBContentOperationActionObserver

- (void)actionPerformedWithContext:(id<HUBActionContext>)context
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
    
    if (protocol == @protocol(HUBContentOperationWithPaginatedContent)) {
        return (self.paginatedContentLoadingBlock != nil);
    }
    
    return [super conformsToProtocol:protocol];
}

@end

NS_ASSUME_NONNULL_END
