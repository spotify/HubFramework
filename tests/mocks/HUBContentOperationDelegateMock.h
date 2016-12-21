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
#import "HUBContentOperation.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content operation delegate. Records all delegate messages sent to it.
@interface HUBContentOperationDelegateMock : NSObject <HUBContentOperationDelegate>

/// All content operation that has sent the `-contentOperationDidFinish:` message.
@property (nonatomic, copy, readonly) NSArray<id<HUBContentOperation>> *finishedContentOperations;
/// All content operation that has sent the `-contentOperation:didFailWithError:` message and the error passed.
@property (nonatomic, copy, readonly) NSMapTable<id<HUBContentOperation>, NSError *> *failedContentOperations;
/// All content operation that has sent the `-contentOperationRequiresRescheduling:` message.
@property (nonatomic, copy, readonly) NSArray<id<HUBContentOperation>> *rescheduledContentOperations;

@end

NS_ASSUME_NONNULL_END
