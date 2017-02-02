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

/// Enum defining various selection states that a component can be in
typedef NS_ENUM(NSInteger, HUBComponentSelectionState) {
    /// The component is neither selected or highlighted
    HUBComponentSelectionStateNone,
    /// The component is currently highlighted through a user interaction
    HUBComponentSelectionStateHighlighted,
    /// The component has been selected, either programmatically or by the user
    HUBComponentSelectionStateSelected
};

/**
 *  Extended Hub component protocol that adds the ability to respond to selection events
 *
 *  Use this protocol if your component adjusts its appearance when the user interacts with it,
 *  such as when the user highlights it through a touch down, or selects it through a tap.
 *
 *  For more information, see `HUBComponent` and `HUBComponentSelectionState`.
 */
@protocol HUBComponentWithSelectionState <HUBComponent>

/**
 *  Update the components view for a certain selection state
 *
 *  @param selectionState The new selection state that the component's view should be updated for
 *
 *  The Hub Framework automatically sends this message to a component when the user either highlights
 *  it (by touching down), or selects it (by tapping).
 */
- (void)updateViewForSelectionState:(HUBComponentSelectionState)selectionState NS_SWIFT_NAME(updateViewForSelectionState(_:));

@end
