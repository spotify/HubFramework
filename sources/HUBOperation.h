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

NS_ASSUME_NONNULL_BEGIN

/// Block type for completion handlers used with Hub Framework operations
typedef void(^HUBOperationCompletionBlock)(void);

/// Block type for synchronous Hub Framework operations
typedef void(^HUBOperationSynchronousBlock)(void);

/// Block type for asynchronous Hub Framework operations
typedef void(^HUBOperationAsynchronousBlock)(HUBOperationCompletionBlock _Nonnull);

/**
 *  Class used to define atomic bodies of work as operations, that can either be synchronous or asynchronous
 *
 *  Why not use `NSOperations`? While `NSOperations` are great for scheduling work on background threads and
 *  dealing with other forms of asynchronosity and managing dependencies between various tasks, they're very
 *  cumbersome (& overkill) to use for simple operations that always should be executed in sequence on the
 *  same thread. If this operation implementation ever becomes more complex, and in the need for some of the
 *  features that `NSOperations` offers, we should totally replace it.
 */
@interface HUBOperation : NSObject

/**
 *  Create an operation that executes a block synchronously
 *
 *  @param block The block that makes up the operation
 *
 *  An operation constructed this way will call its completion handler directly after executing its block.
 */
+ (HUBOperation *)synchronousOperationWithBlock:(HUBOperationSynchronousBlock)block;

/**
 *  Create an operation that executes a block asynchronously
 *
 *  @param block The block that makes up the operation
 *
 *  An operation constructed this way will call its completion handler once its block's completion handler
 *  has been called.
 */
+ (HUBOperation *)asynchronousOperationWithBlock:(HUBOperationAsynchronousBlock)block;

/**
 *  Perform the operation with a completion handler
 *
 *  @param completionHandler A completion handler that will be called once the operation was finished
 */
- (void)performWithCompletionHandler:(HUBOperationCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
