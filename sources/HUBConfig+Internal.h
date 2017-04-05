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

#import "HUBConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class HUBComponentDefaults;
@class HUBActionRegistryImplementation;
@class HUBComponentRegistryImplementation;

/**
 *  Additions to HUBConfig used internally for creation (from the `HUBConfigBuilder`) and
 *  exposing the `HUBComponentDefaults` which is internal.
 */
@interface HUBConfig ()

/// The component defaults.
@property(nonatomic, strong) HUBComponentDefaults *componentDefaults;

/**
 *  Internal initializer only used by the `HUBConfigBuilder`.
 *
 *  @param componentLayoutManager The component layout manager.
 *  @param componentFallbackHandler The component fallback handler.
 *  @param componentDefaults The component defaults.
 *  @param JSONSchema The JSON Schema.
 *  @param imageLoaderFactory The image loader factory.
 *  @param connectivityStateResolver The connectivity state resolver.
 *  @param actionRegistry The action registry.
 *  @param componentRegistry The component registry.
 *  @param contentReloadPolicy The content reload policy.
 *  @param iconImageResolver The icon image resolver.
 *  @param viewControllerScrollHandler The view controller scroll handler.
 *
 *  See `HUBConfig` for more in-depth description of the various parameters.
 */
- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                             componentDefaults:(HUBComponentDefaults *)componentDefaults
                                    jsonSchema:(id<HUBJSONSchema>)JSONSchema
                            imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                     connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                                actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                           contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
                             iconImageResolver:(nullable id<HUBIconImageResolver>) iconImageResolver
                   viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler;

@end

NS_ASSUME_NONNULL_END
