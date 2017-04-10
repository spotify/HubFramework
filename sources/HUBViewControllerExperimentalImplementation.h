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

#import "HUBViewController.h"

@protocol HUBFeatureInfo;
@protocol HUBComponentRegistry;
@protocol HUBComponentLayoutManager;
@protocol HUBActionHandler;
@protocol HUBViewControllerScrollHandler;
@protocol HUBImageLoader;
@protocol HUBViewModelLoader;
@class HUBCollectionViewFactory;
@class HUBComponentReusePool;

NS_ASSUME_NONNULL_BEGIN

/// Extension enabling a HUBViewControllerExperimentalImplementation instance to be initialized by the framework
@interface HUBViewControllerExperimentalImplementation : HUBViewController

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewURI The view URI that this view controller is for
 *  @param featureInfo Information about the feature that the view controller is for
 *  @param viewModelLoader The object to use to load view models for the view controller
 *  @param collectionViewFactory The factory to use to create collection views
 *  @param componentRegistry The registry to use to lookup component information
 *  @param componentReusePool The reuse pool to use to manage component wrappers
 *  @param componentLayoutManager The object that manages layout for components in the view controller
 *  @param actionHandler The object that will handle actions for this view controller
 *  @param scrollHandler The object that will handle scrolling for the view controller
 *  @param imageLoader The loader to use to load images for components
 */
- (instancetype)initWithViewURI:(NSURL *)viewURI
                    featureInfo:(id<HUBFeatureInfo>)featureInfo
                viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader
          collectionViewFactory:(HUBCollectionViewFactory *)collectionViewFactory
              componentRegistry:(id<HUBComponentRegistry>)componentRegistry
             componentReusePool:(HUBComponentReusePool *)componentReusePool
         componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                  actionHandler:(id<HUBActionHandler>)actionHandler
                  scrollHandler:(id<HUBViewControllerScrollHandler>)scrollHandler
                    imageLoader:(id<HUBImageLoader>)imageLoader
                    application:(UIApplication *)application NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// Use `HUBViewControllerFactory` to create instances of this class
+ (instancetype)new NS_UNAVAILABLE;

/// Use `HUBViewControllerFactory` to create instances of this class
- (instancetype)init NS_UNAVAILABLE;

/// Use `HUBViewControllerFactory` to create instances of this class
- (instancetype)initWithCoder:(NSCoder *)decoder NS_UNAVAILABLE;

/// Use `HUBViewControllerFactory` to create instances of this class
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil
                         bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
