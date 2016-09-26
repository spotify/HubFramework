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

@protocol HUBComponentModel;
@protocol HUBComponentWrapperDelegate;
@class HUBComponentRegistryImplementation;
@class HUBComponentWrapper;
@class HUBComponentUIStateManager;

NS_ASSUME_NONNULL_BEGIN

/// Reuse pool that keeps track of component wrappers that may be reused for other models
@interface HUBComponentReusePool : NSObject

/**
 *  Initialize an instance of this class with a component registry and a UI state manager
 *
 *  @param componentRegistry The component registry to use to create new component instances
 *  @param UIStateManager The manager keeping track of component UI states
 */
- (instancetype)initWithComponentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                           UIStateManager:(HUBComponentUIStateManager *)UIStateManager HUB_DESIGNATED_INITIALIZER;

/**
 *  Add a component wrapper to the reuse pool, enabling it to be used for other models
 *
 *  @param componentWrapper The wrapper to add to the pool
 */
- (void)addComponentWrappper:(HUBComponentWrapper *)componentWrapper;

/**
 *  Retrieve a component wrapper from the pool for a given model
 *
 *  @param model The model to return a component wrapper for
 *  @param delegate The object that will act as the component wrapper's delegate
 *  @param parent The parent wrapper if creating a child component
 *
 *  This method will either return a reused wrapper, or create one if none existed in the pool.
 */
- (HUBComponentWrapper *)componentWrapperForModel:(id<HUBComponentModel>)model
                                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                                           parent:(nullable HUBComponentWrapper *)parent;

@end

NS_ASSUME_NONNULL_END
