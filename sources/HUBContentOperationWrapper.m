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

#import "HUBContentOperationWrapper.h"

#import "HUBContentOperationContextImplementation.h"
#import "HUBContentOperationWithPaginatedContent.h"
#import "HUBUtilities.h"

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
                       featureInfo:(id<HUBFeatureInfo>)featureInfo
                 connectivityState:(HUBConnectivityState)connectivityState
                  viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                         pageIndex:(nullable NSNumber *)pageIndex
                     previousError:(nullable NSError *)previousError
{
    self.isExecuting = YES;

    id<HUBContentOperationContext> const context = ({
        [[HUBContentOperationContextImplementation alloc] initWithViewURI:viewURI
                                                              featureInfo:featureInfo
                                                        connectivityState:connectivityState
                                                         viewModelBuilder:viewModelBuilder
                                                            previousError:previousError];
    });

    if (pageIndex != nil) {
        [self appendContentForPageIndex:pageIndex.unsignedIntegerValue context:context];
    } else {
        [self.contentOperation performInContext:context];
    }
}

- (void)appendContentForPageIndex:(NSUInteger)pageIndex context:(id<HUBContentOperationContext>)context
{
    if (HUBConformsToProtocol(self.contentOperation, @protocol(HUBContentOperationWithPaginatedContent))) {
        id<HUBContentOperationWithPaginatedContent> const paginatedOperation = (id<HUBContentOperationWithPaginatedContent>)self.contentOperation;
        [paginatedOperation appendContentForPageIndex:pageIndex inContext:context];
    } else {
        [self finishWithError:context.previousError];
    }
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
