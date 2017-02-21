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
#import "HUBGestureRecognizerSynchronizer.h"

@interface HUBComponentGestureRecognizerTests : XCTestCase

@property (nonatomic, strong) HUBComponentGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) id<HUBGestureRecognizerSynchronizing> mockSynchronizer;

@end

@implementation HUBComponentGestureRecognizerTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];

    self.mockSynchronizer = [HUBGestureRecognizerSynchronizer new];
    self.gestureRecognizer = [[HUBComponentGestureRecognizer alloc] initWithSynchronizer:self.mockSynchronizer];
    self.view =  [[UIView alloc] initWithFrame:CGRectZero];;
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)tearDown
{
    self.gestureRecognizer = nil;
    self.view = nil;
    self.mockSynchronizer = nil;

    [super tearDown];
}

#pragma mark - Tests

- (void)testGestureRecognizerAddedToView
{
    XCTAssertEqual(self.gestureRecognizer.view, self.view);
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

- (void)testTouchesCancelledSetsCancelledState
{
    NSSet<UITouch *> *touches = [NSSet setWithObject:[UITouch new]];

    [self.gestureRecognizer touchesBegan:touches withEvent:[UIEvent new]];
    [self.gestureRecognizer touchesCancelled:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];

    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateCancelled);
}

- (void)testManualCancelSetsCancelledState
{
    NSSet<UITouch *> *touches = [NSSet setWithObject:[UITouch new]];

    [self.gestureRecognizer touchesBegan:touches withEvent:[UIEvent new]];
    [self.gestureRecognizer cancel];

    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateCancelled);
}

- (void)testIfInitialTouchLocksAndUnlocksSynchronizer
{
    HUBComponentGestureRecognizer *gr1 = [[HUBComponentGestureRecognizer alloc]
                                          initWithSynchronizer:self.mockSynchronizer];
    HUBComponentGestureRecognizer *gr2 = [[HUBComponentGestureRecognizer alloc]
                                          initWithSynchronizer:self.mockSynchronizer];

    UIView *view1 = [UIView new];
    UIView *view2 = [UIView new];

    [view1 addGestureRecognizer:gr1];
    [view2 addGestureRecognizer:gr2];

    XCTAssertEqual(self.mockSynchronizer.locked, NO);

    [gr1 touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.mockSynchronizer.locked, YES);

    [gr2 touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.mockSynchronizer.locked, YES);

    [gr1 cancel];
    XCTAssertEqual(self.mockSynchronizer.locked, NO);
}

- (void)testIfSecondGestureFailsWhenPerformedSimultaneously
{
    HUBComponentGestureRecognizer *gr1 = [[HUBComponentGestureRecognizer alloc]
                                          initWithSynchronizer:self.mockSynchronizer];
    HUBComponentGestureRecognizer *gr2 = [[HUBComponentGestureRecognizer alloc]
                                          initWithSynchronizer:self.mockSynchronizer];

    UIView *view1 = [UIView new];
    UIView *view2 = [UIView new];

    [view1 addGestureRecognizer:gr1];
    [view2 addGestureRecognizer:gr2];

    XCTAssertEqual(gr1.state, UIGestureRecognizerStatePossible);
    XCTAssertEqual(gr2.state, UIGestureRecognizerStatePossible);

    [gr1 touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];

    XCTAssertEqual(gr1.state, UIGestureRecognizerStateBegan);
    XCTAssertEqual(gr2.state, UIGestureRecognizerStatePossible);

    [gr2 touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];

    XCTAssertEqual(gr1.state, UIGestureRecognizerStateBegan);
    XCTAssertEqual(gr2.state, UIGestureRecognizerStateFailed);
}

@end
