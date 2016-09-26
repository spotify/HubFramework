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

@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/// Class that manages UI state for a component that has restorable UI state
@interface HUBComponentUIStateManager : NSObject

/**
 *  Save a UI state for a component, for a certain model
 *
 *  @param state The UI state to save
 *  @param componentModel The component model to associate the state with
 */
- (void)saveUIState:(id)state forComponentModel:(id<HUBComponentModel>)componentModel;

/**
 *  Restore a previously saved UI state for a component, for a certain model
 *
 *  @param componentModel The component model to return a UI state for
 */
- (nullable id)restoreUIStateForComponentModel:(id<HUBComponentModel>)componentModel;

/**
 *  Remove a previously saved UI state for a component, for a certain model
 *
 *  @param componentModel The component model to remove a saved UI state for
 */
- (void)removeSavedUIStateForComponentModel:(id<HUBComponentModel>)componentModel;

@end

NS_ASSUME_NONNULL_END
