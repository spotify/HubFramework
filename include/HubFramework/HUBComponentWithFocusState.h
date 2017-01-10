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

#import "HUBComponent.h"

/// Enum defining various focus states that a component can be in
typedef NS_ENUM(NSInteger, HUBComponentFocusState) {
    /// The component is not in focus
    HUBComponentFocusStateNone,
    /// The component is in focus, either programmatically or by the user
    HUBComponentFocusStateInFocus
};

/**
 *  Extended Hub component protocol that adds the ability to respond to focus events (tvOS only).
 *
 *  Use this protocol if your component adjusts its appearance when the user focuses on it.
 *
 *  For more information, see `HUBComponent` and `HUBComponentFocusState`.
 */
@protocol HUBComponentWithFocusState <HUBComponent>

/**
 *  Update the components view for a certain focus state
 *
 *  @param focusState The new focus state that the component's view should be updated for
 *
 *  The Hub Framework automatically sends this message to a component when the user focuses on it.
 */
- (void)updateViewForFocusState:(HUBComponentFocusState)focusState NS_SWIFT_NAME(updateViewForFocusState(_:));

@end
