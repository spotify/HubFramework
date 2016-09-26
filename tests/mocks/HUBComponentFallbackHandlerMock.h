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

#import "HUBComponentFallbackHandler.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class HUBComponentDefaults;

/// Mocked component fallback handler, for use in tests only
@interface HUBComponentFallbackHandlerMock : NSObject <HUBComponentFallbackHandler>

/**
 *  Initialize an instance of this class with a set of component defaults
 *
 *  @param componentDefaults The defaults object to set up this fallback handler's default properties using
 */
- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults HUB_DESIGNATED_INITIALIZER;

/**
 *  Add a fallback component to return for a given category
 *
 *  @param component The component to add
 *  @param category The category to add the component for
 *
 *  The mock will stat returning the given component every time it's asked to create a fallback component for
 *  the given category.
 */
- (void)addFallbackComponent:(id<HUBComponent>)component forCategory:(HUBComponentCategory)category;

@end

NS_ASSUME_NONNULL_END
