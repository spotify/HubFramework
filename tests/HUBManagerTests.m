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
#import "HUBContentOperationFactoryMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"

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

- (void)testUsingConvenienceInitializer
{
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    HUBManager * const manager = [[HUBManager alloc] initWithComponentLayoutManager:componentLayoutManager
                                                           componentFallbackHandler:componentFallbackHandler];
    
    [self verifyManager:manager];
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
    
    // Live service should be created if not DEBUG
#ifdef DEBUG
    XCTAssertNotNil(manager.liveService);
#else
    XCTAssertNil(manager.liveService);
#endif
}

@end
