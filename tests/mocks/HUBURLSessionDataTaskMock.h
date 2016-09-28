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

/// Block type used for mocked data task completion handlers
typedef void(^HUBURLSessionDataTaskMockCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

/// Mocked URL session data task, for use in unit tests only
@interface HUBURLSessionDataTaskMock : NSURLSessionDataTask

/// Whether the data task has been started
@property (nonatomic, assign, readonly) BOOL started;

/**
 *  Initialize an instance of this class with a completion handler
 *
 *  @param completionHandler The completion handler to call once the task was finished or failed
 */
- (instancetype)initWithCompletionHandler:(HUBURLSessionDataTaskMockCompletionHandler)completionHandler HUB_DESIGNATED_INITIALIZER;

/**
 *  Successfully finish the task
 *
 *  @param data The data that the task should act like it downloaded
 */
- (void)finishWithData:(NSData *)data;

/**
 *  Fail the task with an error
 *
 *  @param error The error that the task should report
 */
- (void)failWithError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
