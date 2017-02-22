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

#import "HUBComponentGestureRecognizer.h"
#import "HUBGestureRecognizerSynchronizing.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentGestureRecognizer ()
@property (nonatomic, strong, readonly) id<HUBGestureRecognizerSynchronizing> synchronizer;
@end

@implementation HUBComponentGestureRecognizer

#pragma mark - Object lifecycle

- (instancetype)initWithSynchronizer:(id<HUBGestureRecognizerSynchronizing>)synchronizer
{
    NSParameterAssert(synchronizer);

    self = [super initWithTarget:nil action:nil];

    if (self) {
        _synchronizer = synchronizer;
    }

    return self;
}

#pragma mark - Changing state

- (void)begin
{
    self.state = UIGestureRecognizerStateBegan;
    [self.synchronizer gestureRecognizerDidBeginHandlingTouches:self];
}

- (void)beginIfPossible
{
    if ([self.synchronizer gestureRecognizerShouldBeginHandlingTouches:self] == NO) {
        [self finishWithState:UIGestureRecognizerStateFailed];
        return;
    }

    [self begin];
}

- (void)finishWithState:(UIGestureRecognizerState)state
{
    if ([self isHandlingTouch]) {
        [self.synchronizer gestureRecognizerDidFinishHandlingTouches:self];
    }
    self.state = state;
}

#pragma mark - API

- (void)cancel
{
    if ([self isHandlingTouch]) {
        [self finishWithState:UIGestureRecognizerStateCancelled];
    }
}

#pragma mark - UIGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self beginIfPossible];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];

    UITouch * const touch = [touches anyObject];
    CGPoint const touchLocation = [touch locationInView:self.view];

    if (!CGRectContainsPoint(self.view.bounds, touchLocation)) {
        [self finishWithState:UIGestureRecognizerStateFailed];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self finishWithState:UIGestureRecognizerStateEnded];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self cancel];
}

#pragma mark - Helpers

- (BOOL)isHandlingTouch
{
    return self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged;
}

@end

NS_ASSUME_NONNULL_END
