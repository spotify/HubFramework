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

/// Mocked content operation factory, for use in tests only
@interface HUBContentOperationFactoryMock : NSObject <HUBContentOperationFactory>

/// The content operations that the factory is always returning
@property (nonatomic, strong) NSArray<id<HUBContentOperation>> *contentOperations;

/**
 *  Initialize an instance of this class with an array of content operations
 *
 *  @param contentOperations The content operations that this factory is always returning
 */
- (instancetype)initWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
