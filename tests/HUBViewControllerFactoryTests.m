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

#import "HUBViewControllerFactory.h"
#import "HUBViewController.h"
#import "HUBManager.h"
#import "HUBFeatureRegistry.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentOperationFactoryMock.h"
#import "HUBContentOperationMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBViewURIPredicate.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBActionHandlerMock.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentModelBuilder.h"
#import "HUBActionContext.h"

@interface HUBViewControllerFactoryTests : XCTestCase

@property (nonatomic, strong) HUBActionHandlerMock *defaultActionHandler;
@property (nonatomic, strong) HUBContentReloadPolicyMock *defaultContentReloadPolicy;
@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBViewControllerFactoryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.defaultActionHandler = [HUBActionHandlerMock new];
    self.defaultContentReloadPolicy = [HUBContentReloadPolicyMock new];
    
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    self.manager = [[HUBManager alloc] initWithComponentLayoutManager:componentLayoutManager
                                             componentFallbackHandler:componentFallbackHandler
                                            connectivityStateResolver:connectivityStateResolver
                                                   imageLoaderFactory:nil
                                                    iconImageResolver:nil
                                                 defaultActionHandler:self.defaultActionHandler
                                           defaultContentReloadPolicy:self.defaultContentReloadPolicy
                                     prependedContentOperationFactory:nil
                                      appendedContentOperationFactory:nil];
}

- (void)tearDown
{
    self.defaultActionHandler = nil;
    self.defaultContentReloadPolicy = nil;
    self.manager = nil;

    [super tearDown];
}

#pragma mark - Tests

- (void)testCreatingViewControllerForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    HUBContentOperationFactoryMock * const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[contentOperation]];
    
    [self.manager.featureRegistry registerFeatureWithIdentifier:@"feature"
                                               viewURIPredicate:viewURIPredicate
                                                          title:@"Title"
                                      contentOperationFactories:@[contentOperationFactory]
                                            contentReloadPolicy:nil
                                     customJSONSchemaIdentifier:nil
                                                  actionHandler:nil
                                    viewControllerScrollHandler:nil];
    
    XCTAssertTrue([self.manager.viewControllerFactory canCreateViewControllerForViewURI:viewURI]);
    
    HUBViewController * const viewController = [self.manager.viewControllerFactory createViewControllerForViewURI:viewURI];
    XCTAssertEqualObjects(viewController.viewURI, viewURI);
}

- (void)testCreatingViewControllerForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unknown"];
    XCTAssertFalse([self.manager.viewControllerFactory canCreateViewControllerForViewURI:viewURI]);
    XCTAssertNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

- (void)testCreatingViewControllerWithoutFeatureRegistration
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __block BOOL contentOperationCalled = NO;
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        contentOperationCalled = YES;
        return YES;
    };
    
    HUBViewController * const viewController = [self.manager.viewControllerFactory createViewControllerForViewURI:viewURI
                                                                                                contentOperations:@[contentOperation]
                                                                                                featureIdentifier:@"identifier"
                                                                                                     featureTitle:@"Title"];
    
    [viewController viewWillAppear:NO];
    
    XCTAssertTrue(contentOperationCalled);
    XCTAssertEqualObjects(viewController.featureIdentifier, @"identifier");
    XCTAssertEqualObjects(viewController.navigationItem.title, @"Title");
}

- (void)testCreatingViewControllerWithImplicitIdentifiers
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"Hello world";
        return YES;
    };
    
    HUBViewController * const viewController = [self.manager.viewControllerFactory createViewControllerWithContentOperations:@[contentOperation]
                                                                                                                featureTitle:@"Feature"];
    
    [viewController viewWillAppear:NO];
    
    XCTAssertEqualObjects(viewController.featureIdentifier, @"feature");
    XCTAssertEqualObjects(viewController.navigationItem.title, @"Feature");
    XCTAssertEqual(viewController.viewModel.bodyComponentModels.count, 1u);
    XCTAssertEqualObjects(viewController.viewModel.bodyComponentModels[0].title, @"Hello world");
}

- (void)testDefaultContentReloadPolicyUsedIfFeatureDidNotSupplyOne
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    HUBContentOperationFactoryMock * const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[contentOperation]];
    
    [self.manager.featureRegistry registerFeatureWithIdentifier:@"feature"
                                               viewURIPredicate:viewURIPredicate
                                                          title:@"Title"
                                      contentOperationFactories:@[contentOperationFactory]
                                            contentReloadPolicy:nil
                                     customJSONSchemaIdentifier:nil
                                                  actionHandler:nil
                                    viewControllerScrollHandler:nil];
    
    UIViewController * const viewController = [self.manager.viewControllerFactory createViewControllerForViewURI:viewURI];
    [viewController viewWillAppear:YES];
    [viewController viewWillAppear:YES];
    
    XCTAssertEqualObjects(self.defaultContentReloadPolicy.lastViewURI, viewURI);
    XCTAssertEqual(self.defaultContentReloadPolicy.numberOfRequests, (NSUInteger)1);
}

- (void)testDefaultActionHandlerUsedIfFeatureDidNotSupplyOne
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"].title = @"A component";
        return YES;
    };
    
    HUBContentOperationFactoryMock * const contentOperationFactory = [[HUBContentOperationFactoryMock alloc] initWithContentOperations:@[contentOperation]];
    
    [self.manager.featureRegistry registerFeatureWithIdentifier:@"feature"
                                               viewURIPredicate:viewURIPredicate
                                                          title:@"Title"
                                      contentOperationFactories:@[contentOperationFactory]
                                            contentReloadPolicy:nil
                                     customJSONSchemaIdentifier:nil
                                                  actionHandler:nil
                                    viewControllerScrollHandler:nil];
    
    self.defaultActionHandler.block = ^(id<HUBActionContext> context) {
        return YES;
    };
    
    HUBViewController * const viewController = [self.manager.viewControllerFactory createViewControllerForViewURI:viewURI];
    [viewController viewWillAppear:YES];
    
    id<HUBComponentModel> const componentModel = viewController.viewModel.bodyComponentModels[0];
    NSDictionary<NSString *, id> *customData = @{@"custom":@"data"};
    
    [viewController selectComponentWithModel:componentModel customData:customData];
    
    XCTAssertEqual(self.defaultActionHandler.contexts.count, (NSUInteger)1);
    XCTAssertEqualObjects(self.defaultActionHandler.contexts[0].componentModel, componentModel);
    XCTAssertEqualObjects(self.defaultActionHandler.contexts[0].customData, customData);
}

@end
