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

#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentMock.h"
#import "HUBGestureRecognizerMock.h"
#import "HUBTouchPhase.h"

@interface HUBCollectionViewCellTests : XCTestCase

@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBComponentCollectionViewCell *cell;

@end

@implementation HUBCollectionViewCellTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.component = [HUBComponentMock new];
    self.cell = [[HUBComponentCollectionViewCell alloc] initWithFrame:CGRectZero];
}

#pragma mark - Tests

- (void)testIdentifierNotNil
{
    XCTAssertNotNil(self.cell.identifier);
}

- (void)testSelectionForwardingToComponentCollectionViewCell
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    self.cell.component = self.component;
    
    self.cell.selected = YES;
    XCTAssertTrue(componentCell.isSelected);
    
    self.cell.selected = NO;
    XCTAssertFalse(componentCell.isSelected);
}

- (void)testHighlightForwardingToComponentCollectionViewCell
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    self.cell.component = self.component;
    
    self.cell.highlighted = YES;
    XCTAssertTrue(componentCell.isHighlighted);
    
    self.cell.highlighted = NO;
    XCTAssertFalse(componentCell.isHighlighted);
}

- (void)testNoSelectionOrHighlightForwardingForNonCollectionViewCellComponentViews
{
    self.cell.component = self.component;
    
    // Shouldn't generate an exception
    self.cell.selected = YES;
    self.cell.highlighted = YES;
}

- (void)testTouchEventsForwardedToComponentCellGestureRecognizer
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    self.cell.component = self.component;
    
    HUBGestureRecognizerMock * const gestureRecgonizer = [HUBGestureRecognizerMock new];
    [componentCell addGestureRecognizer:gestureRecgonizer];
    
    [self.cell touchesBegan:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseBegan));
    
    [self.cell touchesMoved:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseMoved));
    
    [self.cell touchesEnded:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseEnded));
    
    [self.cell touchesCancelled:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseCancelled));
}

@end
