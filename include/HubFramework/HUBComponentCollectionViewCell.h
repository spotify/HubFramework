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

#import <UIKit/UIKit.h>

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Collection view cell that can be used to display a Hub Framework component
 *
 *  The Hub Framework uses this collection view cell internally to wrap component views, manage their size,
 *  reuse, etc. If you're building a component that uses a nested `UICollectionView` to display child components,
 *  you can use this cell class to easily be able to render your child components.
 */
@interface HUBComponentCollectionViewCell : UICollectionViewCell

/// A unique identifier for the cell, can be used to track this instance in various operations
@property (nonatomic, strong, readonly) NSUUID *identifier;

/**
 *  The component that the collection view is currently displaying
 *
 *  Set this property to replace the component with a new one. The previous component will be removed from the
 *  cell's content view, and the new one added.
 *
 *  When a component has been attached to this cell, it will start managing it in terms of resizing and reuse, so
 *  you don't need to manually send `prepareForReuse` to the component, it will automatically be sent when the cell
 *  itself gets reused.
 */
@property (nonatomic, strong, nullable) id<HUBComponent> component;

@end

NS_ASSUME_NONNULL_END
