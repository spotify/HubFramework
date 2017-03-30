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

@class HUBCollectionView;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol used by `HUBCollectionView`. Extends the system-provided `UICollectionViewDelegate`.
@protocol HUBCollectionViewDelegate <UICollectionViewDelegate>

/**
 *  Return whether the collection view should start scrolling
 *
 *  @param collectionView The collection view that is about to start scrolling
 *
 *  This method will be called every time the collection view is about to start scrolling, returning `NO`
 *  will stop the event from happening.
 */
- (BOOL)collectionViewShouldBeginScrolling:(HUBCollectionView *)collectionView;

@end

/// Collection view subclass used by the Hub Framework to render body components
@interface HUBCollectionView : UICollectionView

/// The collection view's delegate. See `HUBCollectionViewDelegate` for more information.
@property (nonatomic, weak, nullable) id <HUBCollectionViewDelegate> delegate;

/**
 * Returns a reusable cell object located by the identifier. This method will register the cellClass
 * if it is not already registered with the collection view.
 *
 * @param identifier The reuse identifier for the specified cell. This parameter must not be nil.
 * @param indexPath The index path specifying the location of the cell. The data source receives this information when it is asked for the cell and should just pass it along. This method uses the index path to perform additional configuration based on the cell’s position in the collection view.
 * @param cellClass The class of a cell that you want to use in the collection view.
 *
 * @return A valid UICollectionReusableView object.
 */
- (__kindof UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier
                                                             forIndexPath:(NSIndexPath *)indexPath
                                                cellClassWhenUnregistered:(Class)cellClass;

@end

NS_ASSUME_NONNULL_END
