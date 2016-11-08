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

#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Enum describing various mode in which a content operation may be executed
typedef enum : NSUInteger {
    /// The content operation is executed as part of the main content loading chain
    HUBContentOperationExecutionModeMain,
    /// The content operation is executed when loading additional paginated content
    HUBContentOperationExecutionModePagination
} HUBContentOperationExecutionMode;

/**
 *  Info class used to describe how to execute a certain content operation
 *
 *  This class is used by `HUBViewModelLoaderImplementation` to determine in which mode,
 *  and for which index, to execute a content operation as part of its internal queue.
 */
@interface HUBContentOperationExecutionInfo : NSObject

/// The index of the content operation this info object is for
@property (nonatomic, assign, readonly) NSUInteger contentOperationIndex;

/// The execution mode to use when performing the content operation with this info object
@property (nonatomic, assign, readonly) HUBContentOperationExecutionMode executionMode;

/**
 *  Initialize an instance of this class
 *
 *  @param contentOperationIndex The index of the content operation that this object is for
 *  @param executionMode The mode to execute the content operation in
 */
- (instancetype)initWithContentOperationIndex:(NSUInteger)contentOperationIndex
                                executionMode:(HUBContentOperationExecutionMode)executionMode HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
