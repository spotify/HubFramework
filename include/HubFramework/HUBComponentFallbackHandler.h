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

#import "HUBComponentCategories.h"

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by an object that handles fallback behavior for Hub Framework components
 *
 *  You implement this protocol in a single custom object and inject it when setting up the application's
 *  `HUBManager`. The fallback handler helps the Hub Framework assure that a component is always created, 
 *  even if a component model's namespace/name combination couldn't be resolved to a component. The information
 *  provided by a fallback handler is used to set up all component model builders with default values, and
 *  the fallback handler also acts as a last line of defence for backwards compatibility.
 */
@protocol HUBComponentFallbackHandler <NSObject>

/**
 *  The default component namespace, that all component model builders should have when created
 *
 *  This property is read only once by the Hub Framework (when initializing `HUBManager`)
 */
@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;

/**
 *  The default component name, that all component model builders should have when created
 *
 *  This property is read only once by the Hub Framework (when initializing `HUBManager`)
 */
@property (nonatomic, copy, readonly) NSString *defaultComponentName;

/**
 *  The default component category, that all component model builders should have when created
 *
 *  This property is read only once by the Hub Framework (when initializing `HUBManager`)
 */
@property (nonatomic, copy, readonly) HUBComponentCategory defaultComponentCategory;

/**
 *  Create a fallback component to use for a certain category
 *
 *  @param componentCategory The category to return a fallback component for
 *
 *  The Hub Framework will call this method in case no component could be resolved using any registered
 *  `HUBComponentFactory`. The fallback handler must always return a component from this method, and can
 *  optionally use the provided component category to adjust which type of component to return.
 */
- (id<HUBComponent>)createFallbackComponentForCategory:(HUBComponentCategory)componentCategory;

@end

NS_ASSUME_NONNULL_END
