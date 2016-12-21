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

#import <Foundation/Foundation.h>

@class HUBOperation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  An operation queue that keeps executing scheduled operations whenever the previous one finished
 *
 *  See the documentation for `HUBOperation` for a discussion why `NSOperation(Queue)` is not used here.
 */
@interface HUBOperationQueue : NSObject

/**
 *  Add an operation to the queue
 *
 *  @param operation The operation to add
 *
 *  If the queue is empty, the operation will start directly. Otherwise, it'll start whenever the queue
 *  became idle.
 */
- (void)addOperation:(HUBOperation *)operation;

/**
 *  Add an array of operations to the queue
 *
 *  @param operations The operations to add
 *
 *  All operations will be added to the queue before any of them are started. If the queue was empty when
 *  added, the first operation in the array will then start. Otherwise, it'll start whenever the queue
 *  became idle.
 */
- (void)addOperations:(NSArray<HUBOperation *> *)operations;

@end

NS_ASSUME_NONNULL_END
