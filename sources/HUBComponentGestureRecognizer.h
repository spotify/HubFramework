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
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HUBGestureRecognizerSynchronizing;

/// Gesture recognizer used to recognize highlights & selections for a component
@interface HUBComponentGestureRecognizer : UIGestureRecognizer

/**
 *  Initialize an instance of this class with a synchronizer used to keep track of active gesture so only one is
 *  performed at the same time. This is used to prevent interactions with multiple components at the same time
 *  (i.e. multiple selections).
 *
 *  @param synchronizer The HUBGestureRecognizerSynchronizing object keeping track of active gestures.
 */
- (instancetype)initWithSynchronizer:(id<HUBGestureRecognizerSynchronizing>)synchronizer HUB_DESIGNATED_INITIALIZER;

/// Unavailable. Use the designated initializer instead
- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action NS_UNAVAILABLE;

/// Cancel any current gesture that it being recognized (will set the state to cancelled).
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
