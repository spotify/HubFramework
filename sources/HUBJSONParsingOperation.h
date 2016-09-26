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

/// Class representing a JSON parsing operation that is part of a path
@interface HUBJSONParsingOperation : NSObject

/**
 *  Initialize an instance of this class with a block that contains the parsing operation to perform
 *
 *  @param block The block that contains the logic of the parsing operation
 */
- (instancetype)initWithBlock:(NSArray<NSObject *> * _Nullable (^)(NSObject *))block HUB_DESIGNATED_INITIALIZER;

/**
 *  Return an array of parsed values for performing this operation with a certain input
 *
 *  @param input The input to perform the operation with
 *
 *  @return An array of output values that are the product of performing the operation, or nil if the operation
 *  couldn't be successfully performed.
 */
- (nullable NSArray<NSObject *> *)parsedValuesForInput:(NSObject *)input;

@end

NS_ASSUME_NONNULL_END
