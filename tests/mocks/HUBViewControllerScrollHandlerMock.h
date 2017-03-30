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

#import "HUBViewControllerScrollHandler.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked view controller scroll handler, for use in tests only
@interface HUBViewControllerScrollHandlerMock : NSObject <HUBViewControllerScrollHandler>

/// Whether the handler should return that scroll indicators should be shown
@property (nonatomic, assign) BOOL shouldShowScrollIndicators;

/// Whether the handler should return that content insets should automatically be adjusted
@property (nonatomic, assign) BOOL shouldAutomaticallyAdjustContentInsets;

/// The manner in which the keyboard is dismissed when a drag begins
@property (nonatomic, assign) UIScrollViewKeyboardDismissMode keyboardDismissMode;

/// The scroll deceleration rate that the handler should return
@property (nonatomic, assign) CGFloat scrollDecelerationRate;

/// The target content offset that the handler should return
@property (nonatomic, assign) CGPoint targetContentOffset;

/// The last content rect that was sent to the handler when scrolling started
@property (nonatomic, assign, readonly) CGRect startContentRect;

/// The last content rect that was sent to the handler when scrolling ended
@property (nonatomic, assign, readonly) CGRect endContentRect;

/// A block that is called when the scroll handler is notified that scrolling has started.
@property (nonatomic, copy) void (^ _Nullable scrollingWillStartHandler)(CGRect contentRect);

/// A block that is called when the scroll handler is notified that scrolling is ongoing.
@property (nonatomic, copy) void (^ _Nullable scrollingDidScrollHandler)(CGPoint contentOffset);

/// A block that is called when the scroll handler is notified that scrolling has ended.
@property (nonatomic, copy) void (^ _Nullable scrollingDidEndHandler)(CGRect contentRect);

/// A block that can be used instead of the @c contentInset property to determine the content inset.
@property (nonatomic, copy) UIEdgeInsets (^ _Nullable contentInsetHandler)(HUBViewController *controller, UIEdgeInsets proposedOffset);

@end

NS_ASSUME_NONNULL_END
