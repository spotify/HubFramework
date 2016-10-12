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


#import "HUBViewModel.h"
#import "HUBMoveIndexPath.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The @c HUBViewModelDiff class provides a way to visualise changes between
 * two different view models.
 */
@interface HUBViewModelDiff : NSObject

/// The index paths of any body components that were added in the new view model. 
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *insertedBodyComponentIndexPaths;

/// The index paths of any body components that were removed from the new view model. 
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *deletedBodyComponentIndexPaths;

/// The index paths of any body components that were modified in the new view model. 
@property (nonatomic, strong, readonly) NSArray<NSIndexPath *> *reloadedBodyComponentIndexPaths;

/// The index paths of any body components that were modified moved between the two moddels. 
@property (nonatomic, strong, readonly) NSArray<HUBMoveIndexPath *> *movedBodyComponentIndexPaths;

/**
 * Initializes a @c HUBViewModelDiff using the two view models by finding the longest common subsequence
 * between the two models' body components.
 *
 * @param fromViewModel The view model that is being transitioned from.
 * @param toViewModel The view model that is being transitioned to.
 * 
 * @returns An instance of @c HUBViewModelDiff.
 */
+ (instancetype)diffFromViewModel:(id<HUBViewModel>)fromViewModel
                      toViewModel:(id<HUBViewModel>)toViewModel;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
