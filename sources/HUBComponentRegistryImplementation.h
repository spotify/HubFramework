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

#import "HUBComponentRegistry.h"
#import "HUBComponentShowcaseManager.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponent;
@protocol HUBComponentModel;
@protocol HUBComponentFallbackHandler;
@protocol HUBIconImageResolver;
@class HUBComponentDefaults;
@class HUBJSONSchemaRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentRegistry` and `HUBComponentShowcaseManager` APIs
@interface HUBComponentRegistryImplementation : NSObject <HUBComponentRegistry, HUBComponentShowcaseManager>

/**
 *  Initialize an instance of this class with a component fallback handler
 *
 *  @param fallbackHandler The object to use to create fallback components
 *  @param componentDefaults The default component values to use for component models
 *  @param JSONSchemaRegistry The JSON schema registry used in this instance of the Hub Framework
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithFallbackHandler:(id<HUBComponentFallbackHandler>)fallbackHandler
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
