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
#import "HUBScrollPosition.h"

@class HUBViewController;

/**
 *  Protocol used to define custom scroll handlers for Hub Framework view controllers
 *
 *  Each feature can supply a scroll handler when it's being registered with the Hub Framework
 *  (through `HUBFeatureRegistry`). This enables a feature to customize how scrolling is handled
 *  for all view controllers that will be created on its behalf.
 */
@protocol HUBViewControllerScrollHandler <NSObject>

/**
 *  Return whether scroll indicators should be shown in a view controller
 *
 *  @param viewController The view controller in question
 *
 *  The Hub Framework will call this method when a view controller is being set up. The returned
 *  value will be used for both horizontal & vertical scroll indicators.
 */
- (BOOL)shouldShowScrollIndicatorsInViewController:(HUBViewController *)viewController;

/**
 *  Return whether the system's automatic adjustment of content insets should be used for a view controller
 *
 *  @param viewController The view controller in question
 *
 *  The Hub Framework will call this method when a view controller is being set up. The returned value will be
 *  assigned to its `automaticallyAdjustsScrollViewInsets` property, so see the documentation for that property
 *  on `UIViewController` for more information.
 */
- (BOOL)shouldAutomaticallyAdjustContentInsetsInViewController:(HUBViewController *)viewController;

/**
 *  Return the deceleration rate to use for scrolling in a view controller
 *
 *  @param viewController The view controller in question
 *
 *  The Hub Framework will call this method when a view controller is being set up. The returned value will be
 *  assied to the `decelerationRate` property of its internal scroll view.
 */
- (CGFloat)scrollDecelerationRateForViewController:(HUBViewController *)viewController;

/**
 *  Return the content insets to use for a view controller
 *
 *  @param viewController The view controller in question
 *  @param proposedContentInsets The content insets that the Hub Framework is proposing will be used, which is
 *         computed in regards to the view's current navigation bar height and the status bar height of the app.
 *
 *  The Hub Framework will call this method every time a view controller is being laid out, which is usually in
 *  response to that its view model has been changed. The returned value will be assigned to the `contentInset`
 *  property of its internal scroll view.
 */
- (UIEdgeInsets)contentInsetsForViewController:(HUBViewController *)viewController
                         proposedContentInsets:(UIEdgeInsets)proposedContentInsets;

/**
 *  React to that a scrolling event started in a view controller
 *
 *  @param viewController The view controller in question
 *  @param currentContentRect The rectangle of the currently visible content in the view controller's scroll view
 */
- (void)scrollingWillStartInViewController:(HUBViewController *)viewController
                        currentContentRect:(CGRect)currentContentRect;

/**
 *  React to that a scrolling event ended in a view controller
 *
 *  @param viewController The view controller in question
 *  @param currentContentRect The rectangle of the currently visible content in the view controller's scroll view
 */
- (void)scrollingDidEndInViewController:(HUBViewController *)viewController
                     currentContentRect:(CGRect)currentContentRect;

/**
 *  Return the target content offset for when scrolling ended in a view controller
 *
 *  @param viewController The view controller in question
 *  @param velocity The current scrolling velocity
 *  @param contentInset The current content inset of the view controller's scroll view
 *  @param currentContentOffset The current scrolling content offset
 *  @param proposedContentOffset The target content offset that the Hub Framework is proposing will be used
 */
- (CGPoint)targetContentOffsetForEndedScrollInViewController:(HUBViewController *)viewController
                                                    velocity:(CGVector)velocity
                                                contentInset:(UIEdgeInsets)contentInset
                                        currentContentOffset:(CGPoint)currentContentOffset
                                       proposedContentOffset:(CGPoint)proposedContentOffset;

/**
 *  Return the content offset for displaying a component at a certain scroll position.
 *  
 *  @param componentIndex The index of the component to display.
 *  @param scrollPosition The position to display the component at.
 *  @param contentInset The current content inset of the view controller's scroll view
 *  @param contentSize The current content size of the view controller's scroll view
 *  @param viewController The view controller in question.
 */
- (CGPoint)contentOffsetForDisplayingComponentAtIndex:(NSUInteger)componentIndex
                                       scrollPosition:(HUBScrollPosition)scrollPosition
                                         contentInset:(UIEdgeInsets)contentInset
                                          contentSize:(CGSize)contentSize
                                       viewController:(HUBViewController *)viewController;

@end
