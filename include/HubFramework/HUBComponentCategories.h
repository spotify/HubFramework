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

/**
 *  Type for objects that describe a component category to use for fallbacks using `HUBComponentFallbackHandler`
 *
 *  An application using the Hub Framework can declare any number of categories to use when performing fallback logic
 *  for components, in case an unknown component namespace/name combo was encountered.
 *
 *  Ideally, a component category should be generic enough to apply to a range of components with similar visuals and
 *  behavior, but still contain enough information for a `HUBComponentFallbackHandler` to create appropriate fallback
 *  components based on them.
 */
typedef NSString * HUBComponentCategory HUBS_EXTENSIBLE_STRING_ENUM;

/// Category for components that have a header-like appearance, usually used for header components
static HUBComponentCategory const HUBComponentCategoryHeader = @"header";

/// Category for components that have a row-like appearance, with a full screen width and a compact height
static HUBComponentCategory const HUBComponentCategoryRow = @"row";

/// Category for components that have a card-like appearance, that are placable in a grid with compact width & height
static HUBComponentCategory const HUBComponentCategoryCard = @"card";

/// Category for components that have a carousel-like apperance, with a swipeable horizontal set of child components
static HUBComponentCategory const HUBComponentCategoryCarousel = @"carousel";

/// Category for components that have a banner-like appearance, imagery-heavy with a full screen width and compact height
static HUBComponentCategory const HUBComponentCategoryBanner = @"banner";
