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

#import "HUBOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBOperation ()

@property (nonatomic, copy, readonly) HUBOperationAsynchronousBlock block;

@end

@implementation HUBOperation

#pragma mark - Class constructors

+ (HUBOperation *)synchronousOperationWithBlock:(HUBOperationSynchronousBlock)block
{
    return [[HUBOperation alloc] initWithBlock:^(HUBOperationCompletionBlock _Nonnull completionHandler) {
        block();
        completionHandler();
    }];
}

+ (HUBOperation *)asynchronousOperationWithBlock:(HUBOperationAsynchronousBlock)block
{
    return [[HUBOperation alloc] initWithBlock:block];
}

#pragma mark - Initializer

- (instancetype)initWithBlock:(HUBOperationAsynchronousBlock)block
{
    NSParameterAssert(block != nil);
    
    self = [super init];
    
    if (self) {
        _block = [block copy];
    }
    
    return self;
}

#pragma mark - API

- (void)performWithCompletionHandler:(HUBOperationCompletionBlock)completionHandler
{
    self.block(completionHandler);
}

@end

NS_ASSUME_NONNULL_END
