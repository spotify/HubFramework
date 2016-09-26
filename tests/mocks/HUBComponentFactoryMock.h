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

#import "HUBComponentFactoryShowcaseNameProvider.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked component factory, for use in tests only
@interface HUBComponentFactoryMock : NSObject <HUBComponentFactoryShowcaseNameProvider>

/// The components that this factory returns for a given name
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBComponent>> *components;

/// The component names that the factory should declare as showcaseable
@property (nonatomic, strong, nullable) NSArray<NSString *> *showcaseableComponentNames;

/// A map between component names & human readable names that the factory should use to resolve showcasable names
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *showcaseNamesForComponentNames;

/// Initialize an instance of this class with a name:component dictionary of components to create
- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
