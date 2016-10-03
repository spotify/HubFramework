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

#import "HUBInitialViewModelRegistry.h"
#import "HUBViewModelImplementation.h"

@interface HUBInitialViewModelRegistryTests : XCTestCase

@property (nonatomic, strong) HUBInitialViewModelRegistry *registry;

@end

@implementation HUBInitialViewModelRegistryTests

- (void)setUp
{
    [super setUp];
    self.registry = [HUBInitialViewModelRegistry new];
}

- (void)testRegisteringRetrievingAndRemovingInitialViewModel
{
    id<HUBViewModel> const viewModel = [[HUBViewModelImplementation alloc] initWithIdentifier:@"id"
                                                                               navigationItem:nil
                                                                         headerComponentModel:nil
                                                                          bodyComponentModels:@[]
                                                                       overlayComponentModels:@[]
                                                                                 extensionURL:nil
                                                                                   customData:nil];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    [self.registry registerInitialViewModel:viewModel forViewURI:viewURI];
    
    XCTAssertEqual([self.registry initialViewModelForViewURI:viewURI], viewModel);
    
    NSURL * const unknownViewURI = [NSURL URLWithString:@"spotify:some:other:uri"];
    XCTAssertNil([self.registry initialViewModelForViewURI:unknownViewURI]);
    
    [self.registry removeInitialViewModelForViewURI:viewURI];
    XCTAssertNil([self.registry initialViewModelForViewURI:viewURI]);
}

@end
