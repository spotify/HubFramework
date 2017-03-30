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

/**
 *  Default component fallback handler implementation, used for applications that don't supply their own
 *
 *  This fallback handler uses a block (set in the initializer) to create fallback components.
 */
@interface HUBDefaultComponentFallbackHandler : NSObject <HUBComponentFallbackHandler>

/**
 *  Initialize an instance of this class
 *
 *  @param fallbackBlock The block to use to create fallback components. Will be called every time the
 *         fallback handler is asked to create a component.
 */
- (instancetype)initWithFallbackBlock:(id<HUBComponent>(^)(HUBComponentCategory))fallbackBlock HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
