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

#import "HUBCollectionViewLayoutMock.h"

#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentRegistryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewLayoutMock ()

@property (nonatomic, strong, readonly) NSMutableArray<id<HUBViewModel>> *capturedViewModels;
@property (nonatomic, strong, readonly) NSMutableArray<HUBViewModelDiff *> *capturedViewModelDiffs;

@end

@implementation HUBCollectionViewLayoutMock

- (instancetype)init
{
    self = [super initWithComponentRegistry:[HUBComponentRegistryMock new] componentLayoutManager:[HUBComponentLayoutManagerMock new]];
    if (self) {
        _capturedViewModels = [NSMutableArray array];
        _capturedViewModelDiffs = [NSMutableArray array];
    }
    return self;
}

- (void)computeForCollectionViewSize:(CGSize)collectionViewSize
                           viewModel:(id<HUBViewModel>)viewModel
                                diff:(nullable HUBViewModelDiff *)diff
                     addHeaderMargin:(BOOL)addHeaderMargin
{
    [self.capturedViewModels addObject:viewModel];
    HUBViewModelDiff *nonNullDiff = (diff == nil) ? (HUBViewModelDiff *)[NSNull null] : diff;
    [self.capturedViewModelDiffs addObject:nonNullDiff];
}

- (NSUInteger)numberOfInvocations
{
    return self.capturedViewModels.count;
}

- (nullable id<HUBViewModel>)capturedViewModelAtIndex:(NSUInteger)index
{
    if (index >= self.capturedViewModels.count) {
        return nil;
    }

    return self.capturedViewModels[index];
}

- (nullable HUBViewModelDiff *)capturedViewModelDiffAtIndex:(NSUInteger)index
{
    if (index >= self.capturedViewModelDiffs.count) {
        return nil;
    }

    return self.capturedViewModelDiffs[index];
}


@end

NS_ASSUME_NONNULL_END
