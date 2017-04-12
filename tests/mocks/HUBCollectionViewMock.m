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

#import "HUBCollectionViewMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewMock ()

@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *mutableSelectedIndexPaths;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *mutableDeselectedIndexPaths;

@end

@implementation HUBCollectionViewMock

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    if (!(self = [super initWithFrame:CGRectZero collectionViewLayout:layout])) {
        return nil;
    }
    
    _cells = [NSMutableDictionary new];
    _mutableSelectedIndexPaths = [NSMutableSet new];
    _mutableDeselectedIndexPaths = [NSMutableSet new];
    
    return self;
}

#pragma mark - Property overrides

- (BOOL)isDragging
{
    return self.mockedIsDragging;
}

- (NSSet<NSIndexPath *> *)selectedIndexPaths
{
    return [self.mutableSelectedIndexPaths copy];
}

- (NSSet<NSIndexPath *> *)deselectedIndexPaths
{
    return [self.mutableDeselectedIndexPaths copy];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems
{
    NSArray<NSIndexPath *> * const mockedIndexPaths = self.mockedIndexPathsForVisibleItems;
    
    if (mockedIndexPaths != nil) {
        return mockedIndexPaths;
    }
    
    return [super indexPathsForVisibleItems];
}

- (NSArray<UICollectionViewCell *> *)visibleCells
{
    if (self.mockedVisibleCells != nil) {
        NSArray<UICollectionViewCell *> * const visibleCells = self.mockedVisibleCells;
        return visibleCells;
    }
    
    return [super visibleCells];
}

#pragma mark - UICollectionView

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * const mockedCell = self.cells[indexPath];
    
    if (mockedCell != nil) {
        return mockedCell;
    }
    
    return [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

- (nullable UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath];
}

- (void)selectItemAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{
    [super selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    
    if (indexPath != nil) {
        NSIndexPath * const nonNilIndexPath = indexPath;
        [self.mutableSelectedIndexPaths addObject:nonNilIndexPath];
    }
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [super deselectItemAtIndexPath:indexPath animated:animated];
    [self.mutableDeselectedIndexPaths addObject:indexPath];
}

#pragma mark - UIScrollView 

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
    self.appliedScrollViewOffset = contentOffset;
    self.appliedScrollViewOffsetAnimatedFlag = animated;
}

@end

NS_ASSUME_NONNULL_END
