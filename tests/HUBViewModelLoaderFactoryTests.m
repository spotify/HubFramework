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

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentOperationFactoryMock.h"
#import "HUBContentOperationMock.h"
#import "HUBViewModelLoader.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBViewURIPredicate.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"

@interface HUBViewModelLoaderFactoryTests : XCTestCase

@property (nonatomic, strong) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, copy) NSString *defaultComponentNamespace;
@property (nonatomic, strong) HUBContentOperationFactoryMock *prependedContentOperationFactory;
@property (nonatomic, strong) HUBContentOperationFactoryMock *appendedContentOperationFactory;
@property (nonatomic, strong) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;

@end

@implementation HUBViewModelLoaderFactoryTests

- (void)setUp
{
    [super setUp];
    
    self.featureRegistry = [HUBFeatureRegistryImplementation new];
    self.defaultComponentNamespace = @"default";
    self.prependedContentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    self.appendedContentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                                          iconImageResolver:iconImageResolver];
    
    HUBInitialViewModelRegistry * const initialViewModelRegistry = [HUBInitialViewModelRegistry new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:self.featureRegistry
                                                                                        JSONSchemaRegistry:JSONSchemaRegistry
                                                                                  initialViewModelRegistry:initialViewModelRegistry
                                                                                         componentDefaults:componentDefaults
                                                                                 connectivityStateResolver:connectivityStateResolver
                                                                                         iconImageResolver:iconImageResolver
                                                                          prependedContentOperationFactory:self.prependedContentOperationFactory
                                                                           appendedContentOperationFactory:self.appendedContentOperationFactory
                                                                                defaultContentReloadPolicy:nil];
}

- (void)tearDown
{
    self.featureRegistry = nil;
    self.defaultComponentNamespace = nil;
    self.prependedContentOperationFactory = nil;
    self.appendedContentOperationFactory = nil;
    self.viewModelLoaderFactory = nil;

    [super tearDown];
}

- (void)testCreatingViewModelLoaderForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    HUBContentOperationFactoryMock * const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[contentOperation]];
    
    [self.featureRegistry registerFeatureWithIdentifier:@"feature"
                                       viewURIPredicate:viewURIPredicate
                                                  title:@"Title"
                              contentOperationFactories:@[contentOperationFactory]
                                    contentReloadPolicy:nil
                             customJSONSchemaIdentifier:nil
                                          actionHandler:nil
                            viewControllerScrollHandler:nil];
    
    XCTAssertTrue([self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI]);
    XCTAssertNotNil([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testCreatingViewModelLoaderForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unrecognized"];
    XCTAssertFalse([self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI]);
    XCTAssertNil([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testNoContentOperationCreatedThrows
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentOperationFactoryMock * const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[]];
    
    [self.featureRegistry registerFeatureWithIdentifier:@"feature"
                                       viewURIPredicate:viewURIPredicate
                                                  title:@"Title"
                              contentOperationFactories:@[contentOperationFactory]
                                    contentReloadPolicy:nil
                             customJSONSchemaIdentifier:nil
                                          actionHandler:nil
                            viewControllerScrollHandler:nil];
    
    XCTAssertThrows([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testPrependedAndAppendedContentOperationFactories
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    HUBContentOperationFactoryMock * const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[contentOperation]];
    
    [self.featureRegistry registerFeatureWithIdentifier:@"feature"
                                       viewURIPredicate:viewURIPredicate
                                                  title:@"Title"
                              contentOperationFactories:@[contentOperationFactory]
                                    contentReloadPolicy:nil
                             customJSONSchemaIdentifier:nil
                                          actionHandler:nil
                            viewControllerScrollHandler:nil];
    
    HUBContentOperationMock * const prependedOperation = [HUBContentOperationMock new];
    self.prependedContentOperationFactory.contentOperations = @[prependedOperation];
    
    HUBContentOperationMock * const appendedOperation = [HUBContentOperationMock new];
    self.appendedContentOperationFactory.contentOperations = @[appendedOperation];
    
    NSError * const prependedOperationError = [NSError errorWithDomain:@"prepended" code:7 userInfo:nil];
    NSError * const contentOperationError = [NSError errorWithDomain:@"content" code:7 userInfo:nil];
    
    prependedOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        return NO;
    };
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        return NO;
    };
    
    id<HUBViewModelLoader> const viewModelLoader = [self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI];
    [viewModelLoader loadViewModel];
    
    [prependedOperation.delegate contentOperation:prependedOperation didFailWithError:prependedOperationError];
    [contentOperation.delegate contentOperation:contentOperation didFailWithError:contentOperationError];
    
    XCTAssertEqual(prependedOperation.performCount, (NSUInteger)1);
    XCTAssertEqual(appendedOperation.performCount, (NSUInteger)1);
    XCTAssertEqual(contentOperation.performCount, (NSUInteger)1);
    
    // Verify operation chain order by checking error forwarding
    XCTAssertEqualObjects(contentOperation.previousContentOperationError, prependedOperationError);
    XCTAssertEqualObjects(appendedOperation.previousContentOperationError, contentOperationError);
}

@end
