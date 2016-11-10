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

#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBViewModel.h"

@interface HUBSerializationTests : XCTestCase

@end

@implementation HUBSerializationTests

- (void)testSerialization
{
    NSDictionary * const dictionary = [self loadTestData];

    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];

    HUBJSONSchemaImplementation * const schema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                              iconImageResolver:iconImageResolver];

    id<HUBViewModel> const viewModel = [schema viewModelFromJSONDictionary:dictionary];
    NSDictionary * const serialized = [viewModel serialize];
    XCTAssertEqualObjects(dictionary, serialized);

    id<HUBViewModel> const reconstructedViewModel = [schema viewModelFromJSONDictionary:serialized];
    XCTAssertEqualObjects(viewModel, reconstructedViewModel);
}

- (NSDictionary *)loadTestData
{
    NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"HUBSerializationTests" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:nil];
}

@end
