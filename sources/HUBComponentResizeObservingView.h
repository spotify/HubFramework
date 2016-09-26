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

@class HUBComponentResizeObservingView;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBComponentResizeObservingView`
@protocol HUBComponentResizeObservingViewDelegate <NSObject>

/**
 *  Notifies the delegate that a resize observing view was resized
 *
 *  @param view The view that was resized
 */
- (void)resizeObservingViewDidResize:(HUBComponentResizeObservingView *)view;

@end

/**
 *  A view that observes its own size, and by extension its superview's size, and notifies its delegate when it changes
 *
 *  This view locks onto its superview and takes up its entire bounds as its own frame. Whenever its laid out, it then
 *  compares the size of its new frame with its previous frame, and notifies its delegate if its size was changed.
 *
 *  This view is injected into the view of components that conform to `HUBComponentViewObserver`, to be able to notify
 *  them whenever their view was resized.
 */
@interface HUBComponentResizeObservingView : UIView

/// The view's delegate. See `HUBComponentResizeObservingViewDelegate` for more information.
@property (nonatomic, weak, nullable) id<HUBComponentResizeObservingViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
