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

#import "HUBComponentModelImplementation.h"
#import "HUBComponentUIStateManager.h"
#import "HUBComponentWrapper.h"
#import "HUBComponentMock.h"
#import "HUBIdentifier.h"

@interface HUBComponentWrapperTests : XCTestCase <HUBComponentWrapperDelegate>

@property (nonatomic, strong) HUBComponentUIStateManager *UIStateManager;

@end

@implementation HUBComponentWrapperTests

#pragma mark - XCTest

- (void)setUp
{
    [super setUp];
    self.UIStateManager = [HUBComponentUIStateManager new];
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

#pragma mark - Utility

- (HUBComponentWrapper *)componentWrapperForComponent:(id<HUBComponent>)component
                                                model:(id<HUBComponentModel>)model
{
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:self
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

// Below methods are all no-ops implemented out of necessity.

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper willUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper didUpdateSelectionState:(HUBComponentSelectionState)selectionState
{
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childSelectedAtIndex:(NSUInteger)childIndex
{
}

- (BOOL)componentWrapper:(HUBComponentWrapper *)componentWrapper performActionWithIdentifier:(HUBIdentifier *)identifier customData:(NSDictionary<NSString *,id> *)customData
{
    return NO;
}

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapper *)componentWrapper
{
}

- (HUBComponentWrapper *)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponentForModel:(id<HUBComponentModel>)model
{
    HUBComponentMock * const component = [HUBComponentMock new];
    
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:self
                                                   parent:nil];
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponent:(HUBComponentWrapper *)childComponent childView:(UIView *)childView willAppearAtIndex:(NSUInteger)childIndex
{
}

- (void)componentWrapper:(HUBComponentWrapper *)componentWrapper childComponent:(HUBComponentWrapper *)childComponent childView:(UIView *)childView didDisappearAtIndex:(NSUInteger)childIndex
{
}

@end
