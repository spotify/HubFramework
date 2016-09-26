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

#import "HUBActionFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked action factory, for use in unit tests only
@interface HUBActionFactoryMock : NSObject <HUBActionFactory>

/// The actions that this factory will serve, indexed by name
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBAction>> *actions;

/**
 *  Initialize an instance of this class
 *
 *  @param actions The actions that the factory will serve
 */
- (instancetype)initWithActions:(nullable NSDictionary<NSString *, id<HUBAction>> *)actions HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
