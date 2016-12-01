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
@property (nonatomic, strong, nullable) id<HUBViewModel> lastRenderedViewModel;

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
        addHeaderMargin:(BOOL)addHeaderMargin
             completion:(void (^)(void))completionBlock
{
    HUBViewModelDiff *diff;
    if (self.lastRenderedViewModel != nil) {
        id<HUBViewModel> nonnullViewModel = self.lastRenderedViewModel;
        diff = [HUBViewModelDiff diffFromViewModel:nonnullViewModel toViewModel:viewModel];
    }

    HUBCollectionViewLayout * const layout = (HUBCollectionViewLayout *)self.collectionView.collectionViewLayout;

    if (!usingBatchUpdates || diff == nil) {
        [self.collectionView reloadData];
        
        [layout computeForCollectionViewSize:self.collectionView.frame.size
                                   viewModel:viewModel
                                        diff:diff
                             addHeaderMargin:addHeaderMargin];

        /* Below is a workaround for an issue caused by UICollectionView not asking for numberOfItemsInSection
           before viewDidAppear is called or instantly after a call to reloadData. If reloadData is called
           after viewDidAppear has been called, followed by a call to performBatchUpdates, UICollectionView will
           ask for the initial number of items right before the batch updates, and for the new count while inside
           the update block. This will often trigger an assertion if there are any insertions / deletions, as
           the data model has already changed before the update. Forcing a layoutSubviews however, manually
           triggers the numberOfItems call.
         */
        if (usingBatchUpdates && diff == nil) {
            [self.collectionView setNeedsLayout];
            [self.collectionView layoutIfNeeded];
        }
        completionBlock();
    } else {
        void (^updateBlock)() = ^{
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:diff.insertedBodyComponentIndexPaths];
                [self.collectionView deleteItemsAtIndexPaths:diff.deletedBodyComponentIndexPaths];
                [self.collectionView reloadItemsAtIndexPaths:diff.reloadedBodyComponentIndexPaths];
                
                [layout computeForCollectionViewSize:self.collectionView.frame.size
                                           viewModel:viewModel
                                                diff:diff
                                     addHeaderMargin:addHeaderMargin];
                
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
