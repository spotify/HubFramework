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

#import "HUBComponentLayoutManager.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A default component layout manager implementation, used for applications that don't supply their own
 *
 *  This layout manager applies a given `margin` (set in the initializer) to all components, except if
 *  two components are both stackable (vertical), or if a component is full width (horizontal). Adjustment
 *  is also made for centered components.
 */
@interface HUBDefaultComponentLayoutManager : NSObject <HUBComponentLayoutManager>

/**
 *  Initialize an instance of this class
 *
 *  @param margin The margin that this layout manager should use
 */
- (instancetype)initWithMargin:(CGFloat)margin HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
