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

#import "HUBManager.h"
#import "HUBContentOperationMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBComponentMock.h"
#import "HUBViewController.h"
#import "HUBViewControllerFactory.h"
#import "UIViewController+HUBSimulateLayoutCycle.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModel.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBIdentifier.h"
#import "HUBTestUtilities.h"
#import "HUBDefaults.h"

@interface HUBManagerTests : XCTestCase

@end

@implementation HUBManagerTests

#pragma mark - Tests

- (void)testUsingDesignatedInitializer
{
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    HUBManager * const manager = [[HUBManager alloc] initWithComponentLayoutManager:componentLayoutManager
                                                           componentFallbackHandler:componentFallbackHandler
                                                          connectivityStateResolver:nil
                                                                 imageLoaderFactory:nil
                                                                  iconImageResolver:nil
                                                               defaultActionHandler:nil
                                                         defaultContentReloadPolicy:nil
                                                   prependedContentOperationFactory:nil
                                                    appendedContentOperationFactory:nil];
    
    [self verifyManager:manager];
}

- (void)testUsingInitializerWithOnlyLayoutManagerAndFallbackHandler
{
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    HUBManager * const manager = [HUBManager managerWithComponentLayoutManager:componentLayoutManager
                                                      componentFallbackHandler:componentFallbackHandler];
    
    [self verifyManager:manager];
}

- (void)testUsingInitializerWithDefaults
{
    __block BOOL fallbackComponentUsed = NO;
    
    HUBManager * const manager = [HUBManager managerWithComponentMargin:15
                                                 componentFallbackBlock:^id<HUBComponent>(HUBComponentCategory category) {
                                                     XCTAssertEqualObjects(category, HUBComponentCategoryRow);
                                                     fallbackComponentUsed = YES;
                                                     return [HUBComponentMock new];
                                                 }];
    
    [self verifyManager:manager];
    
    // Verify that a view controller created using the manager uses the defaults
    NSURL * const viewURI = [NSURL URLWithString:@"hub:framework"];
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"Component";
        return YES;
    };
    
    id<HUBViewController> const viewController = [manager.viewControllerFactory createViewControllerForViewURI:viewURI
                                                                                           contentOperations:@[contentOperation]
                                                                                           featureIdentifier:@"feature"
                                                                                                featureTitle:@"Feature"];
    
    [viewController hub_simulateLayoutCycle];
    
    // Assert that the component margin given when setting up the manager is used
    CGRect const componentFrame = [viewController frameForBodyComponentAtIndex:0];
    HUBAssertEqualCGFloatValues(componentFrame.origin.x, 15);
    HUBAssertEqualCGFloatValues(componentFrame.origin.y, 15);
    
    // Assert that the fallback component was used
    XCTAssertTrue(fallbackComponentUsed);
    
    // Assert that the default component namespace was used
    XCTAssertEqualObjects(viewController.viewModel.bodyComponentModels[0].componentIdentifier.namespacePart,
                          HUBDefaultComponentNamespace);
}

#pragma mark - Utilities

- (void)verifyManager:(HUBManager *)manager
{
    // All registeries should be created
    XCTAssertNotNil(manager.featureRegistry);
    XCTAssertNotNil(manager.componentRegistry);
    XCTAssertNotNil(manager.actionRegistry);
    XCTAssertNotNil(manager.JSONSchemaRegistry);
    
    // All factories should be created
    XCTAssertNotNil(manager.viewModelLoaderFactory);
    XCTAssertNotNil(manager.viewControllerFactory);
    
    // Showcase manager should be created
    XCTAssertNotNil(manager.componentShowcaseManager);
    
    // Live service should be created only in DEBUG
#if HUB_DEBUG
    XCTAssertNotNil(manager.liveService);
#else
    XCTAssertNil(manager.liveService);
#endif
}

@end
