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

#import "HUBViewURIPredicate.h"

@interface HUBViewURIPredicateTests : XCTestCase

@end

@implementation HUBViewURIPredicateTests

- (void)testPredicateWithViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const predicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    XCTAssertTrue([predicate evaluateViewURI:viewURI]);
    
    NSString * const subviewURIString = [NSString stringWithFormat:@"%@:subview", viewURI.absoluteString];
    NSURL * const subviewURI = [NSURL URLWithString:subviewURIString];
    XCTAssertFalse([predicate evaluateViewURI:subviewURI]);
}

- (void)testPredicateWithRootViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const predicate = [HUBViewURIPredicate predicateWithRootViewURI:viewURI];
    XCTAssertTrue([predicate evaluateViewURI:viewURI]);
    
    NSString * const subviewURIString = [NSString stringWithFormat:@"%@:subview", viewURI.absoluteString];
    NSURL * const subviewURI = [NSURL URLWithString:subviewURIString];
    XCTAssertTrue([predicate evaluateViewURI:subviewURI]);
}

- (void)testPredicateWithRootViewURIAndExcludedViewURI
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    NSString * const subviewURIStringA = [NSString stringWithFormat:@"%@:subviewA", rootViewURI.absoluteString];
    NSURL * const subviewURIA = [NSURL URLWithString:subviewURIStringA];
    
    NSString * const subviewURIStringB = [NSString stringWithFormat:@"%@:subviewB", rootViewURI.absoluteString];
    NSURL * const subviewURIB = [NSURL URLWithString:subviewURIStringB];
    
    NSSet * const excludedViewURIs = [NSSet setWithObject:subviewURIB];
    HUBViewURIPredicate * const predicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI excludedViewURIs:excludedViewURIs];
    
    XCTAssertTrue([predicate evaluateViewURI:rootViewURI]);
    XCTAssertTrue([predicate evaluateViewURI:subviewURIA]);
    XCTAssertFalse([predicate evaluateViewURI:subviewURIB]);
}

- (void)testPredicateWithPredicate
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    NSPredicate * const predicate = [NSPredicate predicateWithFormat:@"absoluteString == %@", viewURI.absoluteString];
    
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithPredicate:predicate];
    XCTAssertTrue([viewURIPredicate evaluateViewURI:viewURI]);
    
    NSString * const subviewURIString = [NSString stringWithFormat:@"%@:subview", viewURI.absoluteString];
    NSURL * const subviewURI = [NSURL URLWithString:subviewURIString];
    XCTAssertFalse([viewURIPredicate evaluateViewURI:subviewURI]);
}

- (void)testPredicateWithBlock
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBViewURIPredicate * const truePredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return YES;
    }];
    
    XCTAssertTrue([truePredicate evaluateViewURI:viewURI]);
    
    HUBViewURIPredicate * const falsePredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return NO;
    }];
    
    XCTAssertFalse([falsePredicate evaluateViewURI:viewURI]);
}

@end
