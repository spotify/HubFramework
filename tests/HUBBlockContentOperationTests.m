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

#import "HUBBlockContentOperation.h"
#import "HUBContentOperationContext.h"
#import "HUBContentOperationContextImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBFeatureInfoImplementation.h"

@interface HUBBlockContentOperationTests : XCTestCase

@end

@implementation HUBBlockContentOperationTests

- (void)testContextMatchesInputParameters
{
    id<HUBContentOperationContext> const originalContext = [self createContext];

    __block BOOL contentOperationCalled = NO;

    HUBContentOperationBlock const block = ^(id<HUBContentOperationContext> context) {
        XCTAssertEqualObjects(context.viewURI, originalContext.viewURI);
        XCTAssertEqualObjects(context.featureInfo, originalContext.featureInfo);
        XCTAssertEqual(context.connectivityState, originalContext.connectivityState);
        XCTAssertEqualObjects(context.viewModelBuilder, originalContext.viewModelBuilder);
        XCTAssertEqualObjects(context.previousError, originalContext.previousError);

        contentOperationCalled = YES;
    };
    HUBBlockContentOperation * const operation = [[HUBBlockContentOperation alloc] initWithBlock:block];

    [operation performInContext:originalContext];
    
    XCTAssertTrue(contentOperationCalled);
}

- (void)testAddingContentToViewModelBuilder
{
    id<HUBContentOperationContext> const originalContext = [self createContext];
    
    HUBBlockContentOperation * const operation = [[HUBBlockContentOperation alloc] initWithBlock:^(id<HUBContentOperationContext> context) {
        context.viewModelBuilder.navigationBarTitle = @"Hello world!";
    }];
    
    [operation performInContext:originalContext];
    
    XCTAssertEqualObjects(originalContext.viewModelBuilder.navigationBarTitle, @"Hello world!");
}
}

#pragma mark - Utilities

- (id<HUBContentOperationContext>)createContext
{
    NSURL * const viewURI = [NSURL URLWithString:@"view-uri"];
    id<HUBFeatureInfo> const featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:@"id" title:@"title"];
    id<HUBViewModelBuilder> const viewModelBuilder = [self createViewModelBuilder];
    NSError * const previousError = [NSError errorWithDomain:@"hubFramework" code:1 userInfo:nil];

    return [[HUBContentOperationContextImplementation alloc] initWithViewURI:viewURI
                                                                 featureInfo:featureInfo
                                                           connectivityState:HUBConnectivityStateOnline
                                                            viewModelBuilder:viewModelBuilder
                                                               previousError:previousError];
}

- (id<HUBViewModelBuilder>)createViewModelBuilder
{
    HUBComponentDefaults * const defaults = [HUBComponentDefaults defaultsForTesting];

    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:defaults
                                                                                      iconImageResolver:nil];
    
    return [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                       componentDefaults:defaults
                                                       iconImageResolver:nil];
}

@end
