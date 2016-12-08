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

/**
 *  A mock collection view layout for testing. The implementation of computeForCollectionViewSize:viewModel:diff:addHeaderMargin:
 *  captures arguments into the
 */
@interface HUBCollectionViewLayoutMock : HUBCollectionViewLayout

/// All captured view models in the order they were captured.
@property (nonatomic, strong, readonly) NSMutableArray<id<HUBViewModel>> *capturedViewModels;
/// All captured view model diffs (or NSNull if nil was captured) in the order they were captured.
@property (nonatomic, strong, readonly) NSMutableArray<HUBViewModelDiff *> *capturedViewModelDiffs;

/// Default constructor takes no arguments.
- (instancetype)init;

@end
