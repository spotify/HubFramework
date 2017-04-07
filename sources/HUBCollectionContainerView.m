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

#import "HUBCollectionContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBCollectionContainerView

- (void)setContainerView:(nullable UICollectionView *)containerView
{
    if (_containerView == containerView) {
        return;
    }

    [_containerView removeFromSuperview];
    _containerView = nil;

    if (containerView != nil) {
        UICollectionView * const nonNilContainerView = containerView;
        _containerView = nonNilContainerView;
        [self insertSubview:nonNilContainerView atIndex:0];
        [self addGestureRecognizer:nonNilContainerView.panGestureRecognizer];
    }
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    self.containerView.backgroundColor = backgroundColor;
}

@end

NS_ASSUME_NONNULL_END
