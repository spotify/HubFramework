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

#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelJSONSchema.h"
#import "HUBMutableJSONPath.h"
#import "HUBViewModel.h"

@interface HUBJSONSchemaRegistryTests : XCTestCase

@property (nonatomic, strong) HUBJSONSchemaRegistryImplementation *registry;

@end

@implementation HUBJSONSchemaRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    
    self.registry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                         iconImageResolver:iconImageResolver];
}

#pragma mark - Tests

- (void)testRegisteringAndRetrievingCustomSchema
{
    id<HUBJSONSchema> const customSchema = [self.registry createNewSchema];
    NSString * const customSchemaIdentifier = @"custom";
    [self.registry registerCustomSchema:customSchema forIdentifier:customSchemaIdentifier];
    XCTAssertEqualObjects([self.registry customSchemaForIdentifier:customSchemaIdentifier], customSchema);
}

- (void)testRetrievingUnknownSchemaReturnsNil
{
    XCTAssertNil([self.registry customSchemaForIdentifier:@"unknown"]);
}

- (void)testRegisteringCustomSchemaWithExistingIdentifierThrows
{
    id<HUBJSONSchema> const customSchema = [self.registry createNewSchema];
    NSString * const customSchemaIdentifier = @"custom";
    [self.registry registerCustomSchema:customSchema forIdentifier:customSchemaIdentifier];
    XCTAssertThrows([self.registry registerCustomSchema:customSchema forIdentifier:customSchemaIdentifier]);
}

- (void)testCopyingSchema
{
    id<HUBJSONSchema> const originalSchema = [self.registry createNewSchema];
    originalSchema.viewModelSchema.navigationBarTitlePath = [[[originalSchema createNewPath] goTo:@"customTitle"] stringPath];
    
    NSString * const schemaIdentifier = @"custom";
    [self.registry registerCustomSchema:originalSchema forIdentifier:schemaIdentifier];
    
    id<HUBJSONSchema> const copiedSchema = [self.registry copySchemaWithIdentifier:schemaIdentifier];
    
    // Make sure the copied schema is not the same instance as the original
    XCTAssertNotEqual(originalSchema, copiedSchema);
    
    // Test schema equality by JSON parsing
    NSString * const title = @"Hub it up!";
    
    NSDictionary * const dictionary = @{
        @"customTitle": title
    };
    
    id<HUBViewModel> const originalViewModel = [originalSchema viewModelFromJSONDictionary:dictionary];
    id<HUBViewModel> const copiedViewModel = [copiedSchema viewModelFromJSONDictionary:dictionary];
    
    XCTAssertEqual(originalViewModel.navigationItem.title, title);
    XCTAssertEqual(originalViewModel.navigationItem.title, copiedViewModel.navigationItem.title);
}

- (void)testCopyingUknownSchemaReturningNil
{
    XCTAssertNil([self.registry copySchemaWithIdentifier:@"unknown"]);
}

@end
