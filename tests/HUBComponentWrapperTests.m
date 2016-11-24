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

#import "HUBComponentModelImplementation.h"
#import "HUBComponentUIStateManager.h"
#import "HUBComponentGestureRecognizer.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentMock.h"
#import "HUBIdentifier.h"

/**
 *  Class extension used to expose the method that the component wrapper uses to handle its gesture recognizer
 *  This is very ugly, but needed since there seems to be no way to get a gesture recognizer to call its targets
 *  during a unit test.
 */
@interface HUBComponentWrapper ()

- (void)handleGestureRecognizer:(HUBComponentGestureRecognizer *)gestureRecognizer;

@end

@interface HUBComponentWrapperTests : XCTestCase <HUBComponentWrapperDelegate>

@property (nonatomic, strong) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong) HUBComponentGestureRecognizer *gestureRecognizer;
@property (nonatomic, assign) HUBComponentSelectionState selectionStateFromWillUpdateDelegateMethod;
@property (nonatomic, assign) HUBComponentSelectionState selectionStateFromDidUpdateDelegateMethod;

@end

@implementation HUBComponentWrapperTests

#pragma mark - XCTest

- (void)setUp
{
    [super setUp];
    
    self.UIStateManager = [HUBComponentUIStateManager new];
    self.gestureRecognizer = [HUBComponentGestureRecognizer new];
}

#pragma mark - Tests

- (void)testComponentStateRestoring
{
    HUBComponentMock *component = [HUBComponentMock new];
    id<HUBComponentModel> model = [self componentModelWithIdentifier:@"model"];
    
    HUBComponentWrapper *componentWrapper = [self componentWrapperForComponent:component model:model];
    component.currentUIState = @"Funky";
    component.supportsRestorableUIState = YES;
    [componentWrapper loadView];
    [componentWrapper configureViewWithModel:model containerViewSize:CGSizeMake(320.0, 480.0)];
    XCTAssertNil([self.UIStateManager restoreUIStateForComponentModel:model], @"State shouldn't be saved before the first configuration");
    
    id<HUBComponentModel> newModel = [self componentModelWithIdentifier:@"new-model"];
    component.currentUIState = @"Groovy";
    [componentWrapper configureViewWithModel:newModel containerViewSize:CGSizeMake(320.0, 480.0)];
    XCTAssertEqualObjects([self.UIStateManager restoreUIStateForComponentModel:model], @"Groovy");
}

- (void)testHighlight
{
    HUBComponentMock * const component = [HUBComponentMock new];
    id<HUBComponentModel> const model = [self componentModelWithIdentifier:@"model"];
    HUBComponentWrapper * const componentWrapper = [self componentWrapperForComponent:component model:model];
    UIView * const superview = [[UIView alloc] initWithFrame:CGRectZero];
    [componentWrapper viewDidMoveToSuperview:superview];
    
    [self.gestureRecognizer touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    [componentWrapper handleGestureRecognizer:self.gestureRecognizer];
    XCTAssertEqual(self.selectionStateFromWillUpdateDelegateMethod, HUBComponentSelectionStateHighlighted);
    XCTAssertEqual(self.selectionStateFromDidUpdateDelegateMethod, HUBComponentSelectionStateNone);
    
    __weak XCTestExpectation * const expectation = [self expectationWithDescription:@"Waiting for highlight"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqual(self.selectionStateFromDidUpdateDelegateMethod, HUBComponentSelectionStateHighlighted);
        
        // Cancelled touches should reset the selection state
        [self.gestureRecognizer touchesCancelled:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
        [componentWrapper handleGestureRecognizer:self.gestureRecognizer];
        XCTAssertEqual(self.selectionStateFromWillUpdateDelegateMethod, HUBComponentSelectionStateNone);
        XCTAssertEqual(self.selectionStateFromDidUpdateDelegateMethod, HUBComponentSelectionStateNone);
    }];
}

- (void)testSelection
{
    HUBComponentMock * const component = [HUBComponentMock new];
    id<HUBComponentModel> const model = [self componentModelWithIdentifier:@"model"];
    HUBComponentWrapper * const componentWrapper = [self componentWrapperForComponent:component model:model];
    UIView * const superview = [[UIView alloc] initWithFrame:CGRectZero];
    [componentWrapper viewDidMoveToSuperview:superview];
    
    [self.gestureRecognizer touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    [componentWrapper handleGestureRecognizer:self.gestureRecognizer];
    
    [self.gestureRecognizer touchesEnded:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    [componentWrapper handleGestureRecognizer:self.gestureRecognizer];
    
    XCTAssertEqual(self.selectionStateFromWillUpdateDelegateMethod, HUBComponentSelectionStateSelected);
    XCTAssertEqual(self.selectionStateFromDidUpdateDelegateMethod, HUBComponentSelectionStateSelected);
}

- (void)testGestureRecognizerAddedAndRemovedFromSuperview
{
    UIView * const superview = [UIView new];
    
    HUBComponentMock * const component = [HUBComponentMock new];
    id<HUBComponentModel> const model = [self componentModelWithIdentifier:@"model"];
    HUBComponentWrapper *componentWrapper = [self componentWrapperForComponent:component model:model];
    [componentWrapper viewDidMoveToSuperview:superview];
    
    XCTAssertEqualObjects(superview.gestureRecognizers, @[self.gestureRecognizer]);
    
    // When a component wrapper is deallocated, the gesture recognizer for it should automatically be removed
    componentWrapper = nil;
    XCTAssertEqualObjects(superview.gestureRecognizers, @[]);
}

#pragma mark - Utility

- (HUBComponentWrapper *)componentWrapperForComponent:(id<HUBComponent>)component
                                                model:(id<HUBComponentModel>)model
{
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:self
                                        gestureRecognizer:self.gestureRecognizer
                                                   parent:nil];
}

- (id<HUBComponentModel>)componentModelWithIdentifier:(NSString *)identifier
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                  type:HUBComponentTypeBody
                                                                 index:0
                                                       groupIdentifier:nil
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:HUBComponentCategoryBanner
                                                                 title:@"title"
                                                              subtitle:@"subtitle"
                                                        accessoryTitle:nil
                                                       descriptionText:nil
                                                         mainImageData:nil
                                                   backgroundImageData:nil
                                                       customImageData:@{}
                                                                  icon:nil
                                                                target:nil
                                                              metadata:nil
                                                           loggingData:nil
                                                            customData:nil
                                                                parent:nil];
}

#pragma mark - HUBComponentWrapperDelegate

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper willUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
    self.selectionStateFromWillUpdateDelegateMethod = selectionState;
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper didUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
    self.selectionStateFromDidUpdateDelegateMethod = selectionState;
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childSelectedAtIndex:(NSUInteger)childIndex customData:(nullable NSDictionary<NSString *, id> *)customData
{
    // No-op
}

- (BOOL)componentWrapper:(HUBComponentWrapper *)componentWrapper performActionWithIdentifier:(HUBIdentifier *)identifier customData:(NSDictionary<NSString *,id> *)customData
{
    return NO;
}

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapper *)componentWrapper
{
    // No-op
}

- (HUBComponentWrapper *)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponentForModel:(id<HUBComponentModel>)model
{
    HUBComponentMock * const component = [HUBComponentMock new];
    
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:self
                                        gestureRecognizer:self.gestureRecognizer
                                                   parent:nil];
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponent:(HUBComponentWrapper *)childComponent childView:(UIView *)childView willAppearAtIndex:(NSUInteger)childIndex
{
    // No-op
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponent:(HUBComponentWrapper *)childComponent childView:(UIView *)childView didDisappearAtIndex:(NSUInteger)childIndex
{
    // No-op
}

@end
