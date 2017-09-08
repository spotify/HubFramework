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

#import "HUBLiveServiceImplementation.h"
#import "HUBManager.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBInputStreamMock.h"
#import "HUBViewController.h"
#import "HUBViewControllerFactory.h"
#import "HUBViewModel.h"

#if HUB_DEBUG

@interface HUBLiveServiceTests : XCTestCase <HUBLiveServiceDelegate>

@property (nonatomic, strong) HUBManager *hubManager;
@property (nonatomic, strong) HUBLiveServiceImplementation *service;
@property (nonatomic, strong) id<HUBContentOperation> contentOperation;

@end

@implementation HUBLiveServiceTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    id<HUBComponentLayoutManager> const layoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const fallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    self.hubManager = [HUBManager managerWithComponentLayoutManager:layoutManager componentFallbackHandler:fallbackHandler];
    self.service = [HUBLiveServiceImplementation new];
    self.service.delegate = self;
}

- (void)tearDown
{
    self.hubManager = nil;
    self.service = nil;
    self.contentOperation = nil;

    [super tearDown];
}

#pragma mark - Tests

- (void)testNetServiceNilPerDefault
{
    XCTAssertNil(self.service.netService);
}

- (void)testStartingAndStoppingService
{
    [self.service startOnPort:7777];
    XCTAssertEqual(self.service.netService.port, 7777);
    
    [self.service stop];
    XCTAssertNil(self.service.netService);
}

- (void)testCreatingAndReusingViewController
{
    HUBInputStreamMock * const stream = [HUBInputStreamMock new];
    
    NSDictionary * const dictionary = @{
        @"title": @"Live!"
    };
    
    stream.data = [NSJSONSerialization dataWithJSONObject:dictionary options:(NSJSONWritingOptions)0 error:nil];;
    XCTAssertNotNil(stream.data);
    
    [self.service startOnPort:7777];
    
    NSNetService * const netService = self.service.netService;
    NSOutputStream * const outputStream = [NSOutputStream outputStreamToFileAtPath:@"/dev/null" append:NO];
    
    [netService.delegate netService:netService
                         didAcceptConnectionWithInputStream:stream
                         outputStream:outputStream];
    
    [stream.delegate stream:stream handleEvent:NSStreamEventHasBytesAvailable];
    
    id<HUBContentOperation> const contentOperation = self.contentOperation;
    XCTAssertNotNil(contentOperation);

    id<HUBViewController>viewController = [self.hubManager.viewControllerFactory createViewControllerWithContentOperations:@[contentOperation]
                                                                                                            featureTitle:@"Test"];
    [viewController viewWillAppear:YES];
    [viewController viewDidLayoutSubviews];

    id<HUBViewModel> const viewModel = viewController.viewModel;
    XCTAssertEqualObjects(viewModel.navigationItem.title, @"Live!");
    
    // Now let's reload the JSON, which should result in the view controller being reused for a new view model
    NSMutableDictionary * const newDictionary = [dictionary mutableCopy];
    newDictionary[@"title"] = @"A new title!";
    
    stream.data = [NSJSONSerialization dataWithJSONObject:newDictionary options:(NSJSONWritingOptions)0 error:nil];;
    XCTAssertNotNil(stream.data);
    
    [stream.delegate stream:stream handleEvent:NSStreamEventHasBytesAvailable];
    
    XCTAssertEqual(self.contentOperation, contentOperation, @"Content operation should have been reused");
    
    id<HUBViewModel> const newViewModel = viewController.viewModel;
    XCTAssertEqualObjects(newViewModel.navigationItem.title, @"A new title!");
}

#pragma mark - HUBLiveServiceDelegate

- (void)liveService:(id<HUBLiveService>)liveService didCreateContentOperation:(nonnull id<HUBContentOperation>)contentOperation
{
    XCTAssertEqual(self.service, liveService);
    self.contentOperation = contentOperation;
}

@end

#endif // DEBUG
