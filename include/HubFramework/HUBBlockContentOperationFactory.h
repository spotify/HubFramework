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

#import "HUBContentOperationFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Type of block used by `HUBBlockContentOperationFactory` to create content operations
typedef NSArray<id<HUBContentOperation>> * _Nonnull (^HUBContentOperationFactoryBlock)(NSURL *);

/**
 *  A concrete content opereation factory implementation that uses a block
 *
 *  You can use this content operation factory in case you want to implement a simple factory that
 *  doesn't need any injected dependencies or complex logic. For more advanced use cases, see the
 *  `HUBContentOperationFactory` protocol, that you can implement in a custom object.
 */
@interface HUBBlockContentOperationFactory : NSObject  <HUBContentOperationFactory>

/**
 *  Initialize an instance of this class with a block that creates content operations
 *
 *  @param block The block used to create content operations. The input parameter of the block will
 *         be the view URI that content operations should be created for. This block will be copied
 *         and called every time this factory is asked to create content operations.
 */
- (instancetype)initWithBlock:(HUBContentOperationFactoryBlock)block HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
