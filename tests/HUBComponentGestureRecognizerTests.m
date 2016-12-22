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

#import <XCTest/XCTest.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "HUBComponentGestureRecognizer.h"
#import "HUBTouchMock.h"

@interface HUBComponentGestureRecognizerTests : XCTestCase

@property (nonatomic, strong) HUBComponentGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) UIView *view;

@end

@implementation HUBComponentGestureRecognizerTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.gestureRecognizer = [HUBComponentGestureRecognizer new];
    self.view =  [[UIView alloc] initWithFrame:CGRectZero];;
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)tearDown
{
    self.gestureRecognizer = nil;
    self.view = nil;

    [super tearDown];
}

#pragma mark - Tests

- (void)testGestureRecognizerAddedToView
{
    XCTAssertEqualObjects(self.gestureRecognizer.view, self.view);
}

- (void)testTouchesBeganSetsBeganState
{
    [self.gestureRecognizer touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateBegan);
}

- (void)testTouchesMovedInsideOfViewDoesNotAffectState
{
    self.view.frame = CGRectMake(0, 0, 300, 300);
    
    HUBTouchMock * const touch = [HUBTouchMock new];
    touch.location = CGPointMake(150, 150);
    
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:touch] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStatePossible);
}

- (void)testTouchesMovedHorizontallyOutsideOfViewSetsFailedState
{
    self.view.frame = CGRectMake(0, 0, 300, 300);
    
    HUBTouchMock * const touch = [HUBTouchMock new];
    touch.location = CGPointMake(-150, 150);
    
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:touch] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testTouchesMovedVerticallyOutsideOfViewSetsFailedState
{
    self.view.frame = CGRectMake(0, 0, 300, 300);
    
    HUBTouchMock * const touch = [HUBTouchMock new];
    touch.location = CGPointMake(150, 500);
    
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:touch] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testTouchesEndedSetsEndedState
{
    [self.gestureRecognizer touchesEnded:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateEnded);
}

- (void)testTouchesEndedWhenAlreadyFailedDoesNotAffectState
{
    HUBTouchMock * const moveTouch = [HUBTouchMock new];
    moveTouch.location = CGPointMake(-150, 150);
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:moveTouch] withEvent:[UIEvent new]];
    
    [self.gestureRecognizer touchesEnded:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testTouchesCancelledSetsFailedState
{
    [self.gestureRecognizer touchesCancelled:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testManualCancelSetsFailedState
{
    [self.gestureRecognizer cancel];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

@end
