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

#import "HUBIdentifier.h"

@interface HUBIdentifierTests : XCTestCase
@end

@implementation HUBIdentifierTests

- (void)testPropertyAssignment
{
    HUBIdentifier * const identifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];

    XCTAssertEqualObjects(identifier.namespacePart, @"namespace");
    XCTAssertEqualObjects(identifier.namePart, @"name");
}

- (void)testComparingTwoEqualIdentifiers
{
    HUBIdentifier * const identifierA = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBIdentifier * const identifierB = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    
    XCTAssertEqualObjects(identifierA, identifierB);
}

- (void)testComparingIdentifiersWithDifferentNamespaceOrNameShouldNotBeEqual
{
    HUBIdentifier * const identifierA = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBIdentifier * const identifierB = [[HUBIdentifier alloc] initWithNamespace:@"otherNamespace" name:@"name"];
    HUBIdentifier * const identifierC = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"otherName"];

    XCTAssertNotEqualObjects(identifierA, identifierB);
    XCTAssertNotEqualObjects(identifierA, identifierC);
}

@end
