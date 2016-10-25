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
#import "HUBViewModel.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A class used to render view models in a collection view.
 */
@interface HUBViewModelRenderer : NSObject

/**
 * Initializes a @c HUBViewModelRenderer with a provided collection view.
 *
 * @param collectionView The collection view to use for rendering.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView HUB_DESIGNATED_INITIALIZER;

/** 
 * Renders the provided view model in the collection view.
 * 
 * @param viewModel The view model to render.
 * @param usingBatchUpdates Whether the renderer should render using batch updates or not.
 * @param animated Whether the renderer should render with animations or not.
 * @param completionBlock The block to be called once the rendering is completed.
 */
- (void)renderViewModel:(id<HUBViewModel>)viewModel
      usingBatchUpdates:(BOOL)usingBatchUpdates
               animated:(BOOL)animated
             completion:(void(^)())completionBlock;

@end

NS_ASSUME_NONNULL_END
