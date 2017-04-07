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

#import <Foundation/Foundation.h>
#import "HUBHeaderMacros.h"

@protocol HUBComponentLayoutManager;
@protocol HUBComponentRegistry;

@class HUBCollectionView;

NS_ASSUME_NONNULL_BEGIN

/// Factory used to create collection views for use in a `HUBViewController`
@interface HUBCollectionViewFactory : NSObject

/**
 Designated initializer.

 @param componentRegistry The registry to use to lookup component information
 @param componentLayoutManager The object that manages layout for components in the view controller
 */
- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry
                   componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager HUB_DESIGNATED_INITIALIZER;

/// Create a collection view. It will be setup with a default layout.
- (HUBCollectionView *)createCollectionView;

@end

NS_ASSUME_NONNULL_END
