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

#import <UIKit/UIKit.h>
#import "HUBHeaderMacros.h"

@protocol HUBViewModel;
@protocol HUBComponentLayoutManager;
@class HUBComponentRegistryImplementation;
@class HUBScrollBehaviorWrapper;

NS_ASSUME_NONNULL_BEGIN

/// Layout object used by collection views within the Hub Framework
@interface HUBCollectionViewLayout : UICollectionViewLayout

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModel The view model to use to compute the layout
 *  @param componentRegistry The registry to use to retrieve components for calculations
 *  @param componentLayoutManager The manager responsible for component layout
 */
- (instancetype)initWithViewModel:(id<HUBViewModel>)viewModel
                componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager HUB_DESIGNATED_INITIALIZER;

/**
 *  Compute this layout for a given collection view size
 *
 *  @param collectionViewSize The size of the collection view that will use this layout
 */
- (void)computeForCollectionViewSize:(CGSize)collectionViewSize;

@end

NS_ASSUME_NONNULL_END
