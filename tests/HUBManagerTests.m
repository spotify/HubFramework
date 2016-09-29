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

@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBManagerTests

- (void)setUp
{
    [super setUp];

    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    self.manager = [[HUBManager alloc] initWithComponentLayoutManager:componentLayoutManager
                                             componentFallbackHandler:componentFallbackHandler
                                            connectivityStateResolver:nil
                                                   imageLoaderFactory:nil
                                                    iconImageResolver:nil
                                                 defaultActionHandler:nil
                                           defaultContentReloadPolicy:nil
                                     prependedContentOperationFactory:nil
                                      appendedContentOperationFactory:nil];
}

- (void)testRegistriesCreated
{
    XCTAssertNotNil(self.manager.featureRegistry);
    XCTAssertNotNil(self.manager.componentRegistry);
    XCTAssertNotNil(self.manager.actionRegistry);
    XCTAssertNotNil(self.manager.JSONSchemaRegistry);
}

- (void)testFactoriesCreated
{
    XCTAssertNotNil(self.manager.viewModelLoaderFactory);
    XCTAssertNotNil(self.manager.viewControllerFactory);
}

- (void)testComponentShowcaseManagerCreated
{
    XCTAssertNotNil(self.manager.componentShowcaseManager);
}

@end
