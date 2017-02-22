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

NS_ASSUME_NONNULL_BEGIN

/**
 *  `HUBGestureRecognizerSynchronizing` object is used to control if `HUBComponentGestureRecognizer`s should be allowed
 *  to handle touches. This can be used for example to prevent multiple `HUBComponentGestureRecognizer`s from performing
 *  simultaneously.
 */
@protocol HUBGestureRecognizerSynchronizing

/**
 *  This method should be called ba a `gesture recognizer` to notify the `synchronizer` that it started handling
 *  touch events.
 *
 *  @note This method must not be called if `-gestureRecognizerShouldBeginHandlingTouches:` returns `NO`.
 *
 *  @param gestureRecognizer A gesture recognizer that started handling touches.
 */
- (void)gestureRecognizerDidBeginHandlingTouches:(HUBComponentGestureRecognizer *)gestureRecognizer;

/**
 *  This method should be called ba a `gesture recognizer` to notify the `synchronizer` that it finished handling
 *  touch events.
 *
 *  @param gestureRecognizer A gesture recognizer that started handling touches.
 */
- (void)gestureRecognizerDidFinishHandlingTouches:(HUBComponentGestureRecognizer *)gestureRecognizer;

/**
 *  `Gesture recognizer` should call this method before calling `-gestureRecognizerDidBeginHandlingTouches:` and move
 *  to a failed state if it returns `NO`. If it returns `YES` it should proceed with handling touches.
 *
 *  @param gestureRecognizer A gesture recognizer that wants to begin handling touches.
 */
- (BOOL)gestureRecognizerShouldBeginHandlingTouches:(HUBComponentGestureRecognizer *)gestureRecognizer;

@end

NS_ASSUME_NONNULL_END
