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

#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentOperationFactoryMock.h"
#import "HUBViewURIPredicate.h"

@interface HUBFeatureRegistryTests : XCTestCase

@property (nonatomic, strong) HUBFeatureRegistryImplementation *registry;

@end

@implementation HUBFeatureRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.registry = [HUBFeatureRegistryImplementation new];
}

- (void)tearDown
{
    self.registry = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testConflictingIdentifiersTriggerAssert
{
    NSString * const identifier = @"identifier";
    
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI];
    id<HUBContentOperationFactory> const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    
    [self.registry registerFeatureWithIdentifier:identifier
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
    
    XCTAssertThrows([self.registry registerFeatureWithIdentifier:identifier
                                                viewURIPredicate:viewURIPredicate
                                                           title:@"Title"
                                       contentOperationFactories:@[contentOperationFactory]
                                             contentReloadPolicy:nil
                                      customJSONSchemaIdentifier:nil
                                                   actionHandler:nil
                                     viewControllerScrollHandler:nil]);
}

- (void)testRegistrationPropertyAssignment
{
    NSString * const featureIdentifier = @"identifier";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI];
    id<HUBContentOperationFactory> const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    NSString * const customJSONSchemaIdentifier = @"JSON Schema";
    
    [self.registry registerFeatureWithIdentifier:featureIdentifier
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:customJSONSchemaIdentifier
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
    
    HUBFeatureRegistration * const registration = [self.registry featureRegistrationForViewURI:rootViewURI];
    XCTAssertEqualObjects(registration.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(registration.featureTitle, @"Title");
    XCTAssertEqual(registration.viewURIPredicate, viewURIPredicate);
    XCTAssertEqualObjects(registration.contentOperationFactories, @[contentOperationFactory]);
    XCTAssertEqualObjects(registration.customJSONSchemaIdentifier, customJSONSchemaIdentifier);
}

- (void)testPredicateViewURIDisqualification
{
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return NO;
    }];
    
    id<HUBContentOperationFactory> const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    
    [self.registry registerFeatureWithIdentifier:@"feature"
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    XCTAssertNil([self.registry featureRegistrationForViewURI:viewURI]);
}

- (void)testFeatureRegistrationOrderDeterminingViewURIEvaluationOrder
{
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return YES;
    }];
    
    id<HUBContentOperationFactory> const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    
    [self.registry registerFeatureWithIdentifier:@"featureA"
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
    
    [self.registry registerFeatureWithIdentifier:@"featureB"
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:viewURI].featureIdentifier, @"featureA");
}

- (void)testUnregisteringFeature
{
    NSString * const identifier = @"Awesome feature";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI];
    id<HUBContentOperationFactory> const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    
    [self.registry registerFeatureWithIdentifier:identifier
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
    
    [self.registry unregisterFeatureWithIdentifier:identifier];
    
    // The feature should now be free to be re-registered without triggering an assert
    [self.registry registerFeatureWithIdentifier:identifier
                                viewURIPredicate:viewURIPredicate
                                           title:@"Title"
                       contentOperationFactories:@[contentOperationFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil
                                   actionHandler:nil
                     viewControllerScrollHandler:nil];
}

@end
