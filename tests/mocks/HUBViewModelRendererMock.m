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

#import "HUBViewModelRendererMock.h"

#import "HUBCollectionViewMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelRendererMock

- (instancetype)init
{
    if (self = [super init]) {
        _completionBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)renderViewModel:(id<HUBViewModel>)viewModel
       inCollectionView:(nonnull UICollectionView *)collectionView
      usingBatchUpdates:(BOOL)usingBatchUpdates
               animated:(BOOL)animated
        addHeaderMargin:(BOOL)addHeaderMargin
             completion:(void(^)(void))completionBlock
{
    [self.completionBlocks addObject:[completionBlock copy]];
}

@end

NS_ASSUME_NONNULL_END
