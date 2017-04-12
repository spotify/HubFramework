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

#import "HUBCollectionViewLayout.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A mock collection view layout for testing. The implementation of computeForCollectionViewSize:viewModel:diff:addHeaderMargin:
 *  captures arguments to the computeForCollectionViewSize:viewModel:diff:addHeaderMargin: method and makes them available to the
 *  test.
 */
@interface HUBCollectionViewLayoutMock : HUBCollectionViewLayout

- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry;

/**
 *  Returns the number of times that computeForCollectionViewSize:viewModel:diff:addHeaderMargin: was called.
 */
- (NSUInteger)numberOfInvocations;

/**
 *  Returns a captured view model from a call to computeForCollectionViewSize:viewModel:diff:addHeaderMargin:
 *  indexed in the order they were captured.
 *  Returns nil if no object exists at the given index.
 */
- (nullable id<HUBViewModel>)capturedViewModelAtIndex:(NSUInteger)index;

/**
 *  Returns a captured view model diff from a call to computeForCollectionViewSize:viewModel:diff:addHeaderMargin:
 *  indexed in the order they were captured.
 *  Returns nil if no object exists at the given index.
 */
- (nullable HUBViewModelDiff *)capturedViewModelDiffAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
