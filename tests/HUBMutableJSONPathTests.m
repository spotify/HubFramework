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

#import "HUBJSONPath.h"
#import "HUBMutableJSONPathImplementation.h"

@interface HUBMutableJSONPathTests : XCTestCase

@end

@implementation HUBMutableJSONPathTests

- (void)testGoTo
{
    id<HUBJSONStringPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"string"] stringPath];
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"string": @"hello"}], @"hello");
}

- (void)testForEach
{
    id<HUBJSONStringPath> const path = [[[[[HUBMutableJSONPathImplementation path] goTo:@"array"] forEach] goTo:@"title"] stringPath];
    NSArray * const dictionaryArray = @[@{@"title": @"one"}, @{@"title": @"two"}];
    NSArray * const expectedOutputArray = @[@"one", @"two"];
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{@"array": dictionaryArray}], expectedOutputArray);
}

- (void)testRunBlock
{
    id<HUBJSONStringPath> const path = [[[[HUBMutableJSONPathImplementation path] goTo:@"string"] runBlock:^id(id input) {
        return @"blockString";
    }] stringPath];
    
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"string": @"nonBlockString"}], @"blockString");
    XCTAssertNil([path stringFromJSONDictionary:@{}]);
}

- (void)testRunBlockTypeSafety
{
    id<HUBJSONStringPath> const pathWithInvalidBlockReturn = [[[[HUBMutableJSONPathImplementation path] goTo:@"string"] runBlock:^id(id input) {
        return @{};
    }] stringPath];
    
    XCTAssertNil([pathWithInvalidBlockReturn stringFromJSONDictionary:@{@"string": @"nonBlockString"}]);
    
    id<HUBJSONStringPath> const extendedPath = [[[[[[HUBMutableJSONPathImplementation path] goTo:@"string"] stringPath] mutableCopy] runBlock:^id(id input) {
        // We're assuming this is a string here, so the preceeding nodes should protect this block
        return [input stringByAppendingString:@"append"];
    }] stringPath];
    
    XCTAssertNil([extendedPath stringFromJSONDictionary:@{@"string": @(15)}]);
}

- (void)testCombiningPaths
{
    id<HUBMutableJSONPath> const pathA = [[HUBMutableJSONPathImplementation path] goTo:@"A"];
    id<HUBMutableJSONPath> const pathB = [[HUBMutableJSONPathImplementation path] goTo:@"B"];
    id<HUBMutableJSONPath> const combinedPath = [pathA combineWithPath:pathB];
    
    NSDictionary * const dictionary = @{
        @"A": @"valueA",
        @"B": @"valueB"
    };
    
    NSArray * const values = [[combinedPath stringPath] valuesFromJSONDictionary:dictionary];
    NSArray * const expectedValues = @[@"valueA", @"valueB"];
    XCTAssertEqualObjects(values, expectedValues);
}

- (void)testCopying
{
    id<HUBMutableJSONPath> const original = [[HUBMutableJSONPathImplementation path] goTo:@"key"];
    id<HUBJSONPath> const copy = [original copy];
    id<HUBMutableJSONPath> const mutableCopy = [copy mutableCopy];
    id<HUBJSONStringPath> const finalPath = [mutableCopy stringPath];
    
    NSDictionary * const dictionary = @{
        @"key": @"value"
    };
    
    XCTAssertEqualObjects([finalPath stringFromJSONDictionary:dictionary], @"value");
}

@end
