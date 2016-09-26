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

/// Protocol adopted by objects that can have touches forwarded to them
@protocol HUBTouchForwardingTarget <NSObject>

/**
 *  Forward a "touches began" event to the target
 *
 *  @param touches The touches that begun
 *  @param event The event to forward
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/**
 *  Forward a "touches moved" event to the target
 *
 *  @param touches The touches that were moved
 *  @param event The event to forward
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/**
 *  Forward a "touches ended" event to the target
 *
 *  @param touches The touches that ended
 *  @param event The event to forward
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/**
 *  Forward a "touches cancelled" event to the target
 *
 *  @param touches The touches that were cancelled
 *  @param event The event to forward
 */
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
