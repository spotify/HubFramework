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

#import "HUBViewModelRenderer.h"
#import "HUBViewModelDiff.h"
#import "HUBCollectionViewLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelRenderer ()

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, strong) id<HUBViewModel> lastRenderedViewModel;

@end

@implementation HUBViewModelRenderer

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        _collectionView = collectionView;
    }
    return self;
}

- (void)renderViewModel:(id<HUBViewModel>)viewModel
      usingBatchUpdates:(BOOL)usingBatchUpdates
               animated:(BOOL)animated
             completion:(void (^)())completionBlock
{
    HUBViewModelDiff *diff;
    if (self.lastRenderedViewModel != nil) {
        diff = [HUBViewModelDiff diffFromViewModel:self.lastRenderedViewModel toViewModel:viewModel];
    }

    HUBCollectionViewLayout * const layout = (HUBCollectionViewLayout *)self.collectionView.collectionViewLayout;

    if (!usingBatchUpdates || diff == nil) {
        [self.collectionView reloadData];
        
        [layout computeForCollectionViewSize:self.collectionView.frame.size viewModel:viewModel diff:diff];

        /* Forcing a re-layout as the reloadData-call doesn't trigger the numberOfItemsInSection:-calls
         by itself, and batch update calls don't play well without having an initial item count. */
        [self.collectionView setNeedsLayout];
        [self.collectionView layoutIfNeeded];
        completionBlock();
    } else {
        void (^updateBlock)() = ^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:diff.insertedBodyComponentIndexPaths];
                [self.collectionView deleteItemsAtIndexPaths:diff.deletedBodyComponentIndexPaths];
                [self.collectionView reloadItemsAtIndexPaths:diff.reloadedBodyComponentIndexPaths];
                
                [layout computeForCollectionViewSize:self.collectionView.frame.size viewModel:viewModel diff:diff];
            } completion:^(BOOL finished) {
                completionBlock();
            }];
        };
        
        if (animated) {
            updateBlock();
        } else {
            [UIView performWithoutAnimation:updateBlock];
        }
    }

    self.lastRenderedViewModel = viewModel;
}

@end

NS_ASSUME_NONNULL_END
