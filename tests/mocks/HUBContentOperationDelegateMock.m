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

#import "HUBContentOperationDelegateMock.h"

@interface HUBContentOperationDelegateMock ()

@property (nonatomic, strong, readonly) NSMutableArray<id<HUBContentOperation>> *mutableFinishedContentOperations;
@property (nonatomic, strong, readonly) NSMapTable<id<HUBContentOperation>, NSError *> *mutableFailedContentOperations;
@property (nonatomic, strong, readonly) NSMutableArray<id<HUBContentOperation>> *mutableRescheduledContentOperations;

@end

@implementation HUBContentOperationDelegateMock

- (instancetype)init
{
    self = [super init];

    if (self) {
        _mutableFinishedContentOperations = [NSMutableArray new];
        _mutableFailedContentOperations = [NSMapTable strongToStrongObjectsMapTable];
        _mutableRescheduledContentOperations = [NSMutableArray new];
    }

    return self;
}

- (NSArray<id<HUBContentOperation>> *)finishedContentOperations
{
    @synchronized(self) {
        return [self.mutableFinishedContentOperations copy];
    }
}

- (NSMapTable<id<HUBContentOperation>, NSError *> *)failedContentOperations
{
    @synchronized(self) {
        return [self.mutableFailedContentOperations copy];
    }
}

- (NSArray<id<HUBContentOperation>> *)rescheduledContentOperations
{
    @synchronized(self) {
        return [self.mutableRescheduledContentOperations copy];
    }
}

#pragma mark HUBContentOperationDelegate

- (void)contentOperationDidFinish:(id<HUBContentOperation>)operation
{
    @synchronized(self) {
        [self.mutableFinishedContentOperations addObject:operation];
    }
}

- (void)contentOperation:(id<HUBContentOperation>)operation didFailWithError:(NSError *)error
{
    @synchronized(self) {
        [self.mutableFailedContentOperations setObject:error forKey:operation];
    }
}

- (void)contentOperationRequiresRescheduling:(id<HUBContentOperation>)operation
{
    @synchronized(self) {
        [self.mutableRescheduledContentOperations addObject:operation];
    }
}

@end
