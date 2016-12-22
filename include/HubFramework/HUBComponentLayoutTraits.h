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

/**
 *  Type for objects that describe a layout trait to use in a `HUBComponentLayoutManager` to compute margins
 *
 *  Margins between various components and the content edge of a view is determined by inspecting the layout traits
 *  of a given component. Each component has the opportunity to declare its traits through the `layoutTraits` property
 *  of `HUBComponent`.
 *
 *  An application using the Hub Framework may declare additional traits using this type, as its up to the implementation
 *  of `HUBComponentLayoutManager` (controlled by the application) to determine how to map traits to absolute margins.
 *
 *  Ideally, a layout trait should be generic enough to apply to a broad range of components, but still contain enough
 *  information for a `HUBComponentLayoutManager` to make correct decisions based on them.
 */
typedef NSString * HUBComponentLayoutTrait HUBS_EXTENSIBLE_STRING_ENUM;

/// Layout trait for components which width does not fill the screen and is considered compact
static HUBComponentLayoutTrait const HUBComponentLayoutTraitCompactWidth = @"compactWidth";

/// Layout trait for components which width fills the screen
static HUBComponentLayoutTrait const HUBComponentLayoutTraitFullWidth = @"fullWidth";

/// Layout trait for components which are stackable on top of each other, without any margin in between
static HUBComponentLayoutTrait const HUBComponentLayoutTraitStackable = @"stackable";

/// Layout trait for components which should be presented on rows which have equal left and right margins
static HUBComponentLayoutTrait const HUBComponentLayoutTraitCentered = @"centered";

/// Layout trait for components which are stackable on top of each other, without any margin in between, regardless of the layout traits the preceding component has
static HUBComponentLayoutTrait const HUBComponentLayoutTraitAlwaysStackUpwards = @"alwaysStackUpwards";

NS_ASSUME_NONNULL_END
