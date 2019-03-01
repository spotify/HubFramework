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

#import "HUBCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked collection view, for use in tests only
@interface HUBCollectionViewMock : HUBCollectionView

/// The cells that the collection view will consider as being part of it
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, UICollectionViewCell *> *cells;

/// The index paths that have been selected in the collection view
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *selectedIndexPaths;

/// The index paths that have been deselected in the collection view
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *deselectedIndexPaths;

/// The index paths of the items that the collection view should act like it's displaying
@property (nonatomic, strong, nullable) NSArray<NSIndexPath *> *mockedIndexPathsForVisibleItems;

/// Any cells that the collection view should act like it's displaying
@property (nonatomic, strong, nullable) NSArray<UICollectionViewCell *> *mockedVisibleCells;

/// The offset that has been scrolled to
@property (nonatomic) CGPoint appliedScrollViewOffset;

/// The animated flag applied when offet is scrolled to.
@property (nonatomic) BOOL appliedScrollViewOffsetAnimatedFlag;

/// Whether the collection view should act like the user is dragging its content
@property (nonatomic) BOOL mockedIsDragging;

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout;

@end

NS_ASSUME_NONNULL_END
