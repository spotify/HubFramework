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

#import <XCTest/XCTest.h>

#import "HUBOperationQueue.h"
#import "HUBOperation.h"

@interface HUBOperationQueueTests : XCTestCase

@property (nonatomic, strong) HUBOperationQueue *queue;

@end

@implementation HUBOperationQueueTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.queue = [HUBOperationQueue new];
}

#pragma mark - Tests

- (void)testAddingSingleOperation
{
    __block BOOL operationPerformed = NO;
    
    HUBOperation * const operation = [HUBOperation synchronousOperationWithBlock:^{
        operationPerformed = YES;
    }];
    
    [self.queue addOperation:operation];
    XCTAssertTrue(operationPerformed);
}

- (void)testWaitingForAsyncOperation
{
    __block HUBOperationCompletionBlock asyncOperationCompletionHandler = nil;
    __block BOOL syncOperationPerformed = NO;
    
    HUBOperation * const asyncOperation = [HUBOperation asynchronousOperationWithBlock:^(HUBOperationCompletionBlock _Nonnull completionHandler) {
        asyncOperationCompletionHandler = completionHandler;
    }];
    
    HUBOperation * const syncOperation = [HUBOperation synchronousOperationWithBlock:^{
        syncOperationPerformed = YES;
    }];
    
    [self.queue addOperations:@[asyncOperation, syncOperation]];
    XCTAssertFalse(syncOperationPerformed);
    
    XCTAssertNotNil(asyncOperationCompletionHandler);
    asyncOperationCompletionHandler();
    XCTAssertTrue(syncOperationPerformed);
}

- (void)testAddingOperationToBusyQueue
{
    __block HUBOperationCompletionBlock asyncOperationCompletionHandler = nil;
    __block BOOL syncOperationPerformed = NO;
    
    HUBOperation * const asyncOperation = [HUBOperation asynchronousOperationWithBlock:^(HUBOperationCompletionBlock _Nonnull completionHandler) {
        asyncOperationCompletionHandler = completionHandler;
    }];
    
    HUBOperation * const syncOperation = [HUBOperation synchronousOperationWithBlock:^{
        syncOperationPerformed = YES;
    }];
    
    [self.queue addOperation:asyncOperation];
    [self.queue addOperation:syncOperation];
    XCTAssertFalse(syncOperationPerformed);
    
    XCTAssertNotNil(asyncOperationCompletionHandler);
    asyncOperationCompletionHandler();
    XCTAssertTrue(syncOperationPerformed);
}

@end
