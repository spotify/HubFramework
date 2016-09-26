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

#import "HUBGestureRecognizerMock.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "HUBTouchPhase.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBGestureRecognizerMock ()

@property (nonatomic, strong, nullable, readwrite) NSValue *touchPhaseValue;

@end

@implementation HUBGestureRecognizerMock

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseBegan);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseMoved);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseEnded);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseCancelled);
}

@end

NS_ASSUME_NONNULL_END
