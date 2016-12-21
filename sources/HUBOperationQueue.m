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

#import "HUBOperationQueue.h"

#import "HUBOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBOperationQueue ()

@property (nonatomic, strong, readonly) NSMutableArray<HUBOperation *> *operations;

@end

@implementation HUBOperationQueue

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _operations = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - API

- (void)addOperation:(HUBOperation *)operation
{
    [self addOperations:@[operation]];
}

- (void)addOperations:(NSArray<HUBOperation *> *)operations
{
    BOOL shouldPerformFirstOperation = (self.operations.count == 0);
    [self.operations addObjectsFromArray:operations];
    
    if (shouldPerformFirstOperation) {
        [self performFirstOperation];
    }
}

#pragma mark - Private utilities

- (void)performFirstOperation
{
    HUBOperation * const operation = self.operations.firstObject;
    
    if (operation == nil) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    
    [operation performWithCompletionHandler:^{
        __typeof(self) strongSelf = weakSelf;
        
        if (strongSelf == nil) {
            return;
        }
        
        [strongSelf.operations removeObjectAtIndex:0];
        [strongSelf performFirstOperation];
    }];
}

@end

NS_ASSUME_NONNULL_END
