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

#import "HUBViewControllerFactory.h"
#import "HUBHeaderMacros.h"

@protocol HUBImageLoaderFactory;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBActionHandler;
@class HUBViewModelLoaderFactoryImplementation;
@class HUBFeatureRegistryImplementation;
@class HUBComponentRegistryImplementation;
@class HUBInitialViewModelRegistry;
@class HUBActionRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewControllerFactory` API
@interface HUBViewControllerFactoryImplementation : NSObject <HUBViewControllerFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModelLoaderFactory The factory to use to create view model loaders
 *  @param featureRegistry The feature registry to use to retrieve information about registered features
 *  @param componentRegistry The component registry to use in the view controllers that this factory creates
 *  @param initialViewModelRegistry The registry to use to retrieve pre-computed view models for initial content
 *  @param actionRegistry The registry to use to retrieve actions for events occuring in a view controller
 *  @param defaultActionHandler Any user-defined action handler to use for features that don't define their own
 *  @param componentLayoutManager The object that manages layout for components for created view controllers
 *  @param imageLoaderFactory The factory to use to create image loaders
 */
- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                               featureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                                actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
                          defaultActionHandler:(nullable id<HUBActionHandler>)defaultActionHandler
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                            imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
                                   application:(UIApplication *)application HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
