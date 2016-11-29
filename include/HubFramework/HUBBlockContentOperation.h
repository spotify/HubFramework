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

#import "HUBContentOperation.h"
#import "HUBHeaderMacros.h"

@protocol HUBContentOperationContext;

NS_ASSUME_NONNULL_BEGIN

/**
 *  A concrete content operation type that is executed using a block
 *
 *  You can use this type to implement lightweight content operations, that don't have the need
 *  to be asynchronous or support rescheduling. You simply give a block when initializing an
 *  instance of this class, and that block becomes the body of the content operation.
 *
 *  For more flexibility, implement your own content operation using `HUBContentOperation`.
 */
@interface HUBBlockContentOperation : NSObject <HUBContentOperation>

/**
 *  Initialize an instance of this class
 *
 *  @param block The block to use for the operation. The block will be copied by the operation and
 *         invoked each time the operation is performed. The contextual object passed to the block
 *         will contain all execution parameters that are passed to any `HUBContentOperation`.
 */
- (instancetype)initWithBlock:(void(^)(id<HUBContentOperationContext>))block HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
