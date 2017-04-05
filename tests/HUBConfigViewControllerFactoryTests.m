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
#import "HUBConfig+Testing.h"
#import "HUBContentOperationMock.h"
#import "HUBConfigViewControllerFactory.h"
#import "HUBViewController.h"


@interface HUBConfigViewControllerFactoryTests : XCTestCase
@end


@implementation HUBConfigViewControllerFactoryTests

- (void)testFactoryCanCreateViewController
{
    HUBConfigViewControllerFactory * const factory = [HUBConfigViewControllerFactory new];
    HUBConfig * const config = [HUBConfig configForTesting];
    id<HUBContentOperation> contentOperation = [HUBContentOperationMock new];
    NSURL *viewURI = (id)[NSURL URLWithString:@"test-uri"];

    HUBViewController * const viewController = [factory createViewControllerWithConfig:config
                                                                     contentOperations:@[contentOperation]
                                                                               viewURI:viewURI
                                                                     featureIdentifier:@"test"
                                                                          featureTitle:@"Test"
                                                                         actionHandler:nil];
    XCTAssertEqualObjects(viewController.viewURI, viewURI);
}
@end
