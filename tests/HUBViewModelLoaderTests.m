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

#import "HUBViewModelLoaderImplementation.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModelImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBContentOperationMock.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"
#import "HUBFeatureInfoImplementation.h"

@interface HUBViewModelLoaderTests : XCTestCase <HUBViewModelLoaderDelegate>

@property (nonatomic, strong) HUBViewModelLoaderImplementation *loader;
@property (nonatomic, strong) id<HUBFeatureInfo> featureInfo;
@property (nonatomic, strong) HUBContentReloadPolicyMock *contentReloadPolicy;
@property (nonatomic, strong) HUBConnectivityStateResolverMock *connectivityStateResolver;
@property (nonatomic, strong) id<HUBViewModel> viewModelFromSuccessDelegateMethod;
@property (nonatomic, strong) NSError *errorFromFailureDelegateMethod;

@property (nonatomic, assign) NSUInteger didLoadViewModelCount;
@property (nonatomic, assign) NSUInteger didLoadViewModelErrorCount;

@end

@implementation HUBViewModelLoaderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:@"id" title:@"title"];
    self.contentReloadPolicy = [HUBContentReloadPolicyMock new];
    self.connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    self.didLoadViewModelCount = 0;
    self.didLoadViewModelErrorCount = 0;
}

- (void)tearDown
{
    self.loader = nil;
    self.featureInfo = nil;
    self.contentReloadPolicy = nil;
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    self.connectivityStateResolver = nil;
    self.viewModelFromSuccessDelegateMethod = nil;
    self.errorFromFailureDelegateMethod = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testInitialViewModel
{
    __block NSUInteger numberOfInitialViewModelRequests = 0;
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        numberOfInitialViewModelRequests++;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationItem.title, @"A title");
    
    // The initial view model should now be cached, so accessing it shouldn't increment the request count
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationItem.title, @"A title");
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationItem.title, @"A title");
    
    XCTAssertEqual(numberOfInitialViewModelRequests, 1u);
}

- (void)testInjectedInitialViewModelUsedInsteadOfContentOperations
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
    
    HUBViewModelBuilderImplementation * const viewModelBuilder = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                                                             componentDefaults:componentDefaults
                                                                                                             iconImageResolver:iconImageResolver];
    
    viewModelBuilder.navigationBarTitle = @"Pre-computed title";
    
    id<HUBViewModel> const initialViewModel = [viewModelBuilder build];
    
    __block BOOL contentOperationCalled = NO;
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        contentOperationCalled = YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:initialViewModel];
    
    XCTAssertEqualObjects(self.loader.initialViewModel.navigationItem.title, @"Pre-computed title");
    XCTAssertFalse(contentOperationCalled);
}

- (void)testSuccessfullyLoadingViewModel
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [contentOperation.delegate contentOperationDidFinish:contentOperation];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationItem.title, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSingleContentOperationError
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperation.delegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertEqual(error, self.errorFromFailureDelegateMethod);
}

- (void)testContentOperationErrorRecovery
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builder.navigationBarTitle = @"A title";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperationA.delegate contentOperation:contentOperationA didFailWithError:error];
    
    XCTAssertEqualObjects(contentOperationB.previousContentOperationError, error);
    [contentOperationB.delegate contentOperationDidFinish:contentOperationB];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationItem.title, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testViewModelBuilderCopiedBetweenContentOperations
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> builderA = nil;
    __block id<HUBViewModelBuilder> builderB = nil;
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builderA = builder;
        return YES;
    };
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        builderB = builder;
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNotEqual(builderA, builderB);
}

- (void)testAsynchronousContentOperationMultipleDelegateCallbacksIgnored
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> viewModelBuilder = nil;
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        viewModelBuilder = builder;
        viewModelBuilder.navigationBarTitle = @"A title";
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperation.delegate;
    
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationItem.title, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    
    viewModelBuilder.navigationBarTitle = @"Another title";
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationItem.title, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);

    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    [contentOperationDelegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationItem.title, @"A title");
    XCTAssertNil(self.errorFromFailureDelegateMethod);
}

- (void)testSynchronousContentOperationCallingSuccessCallback
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperationA) weakContentOperationA = contentOperationA;
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperationA) strongContentOperationA = weakContentOperationA;
        [strongContentOperationA.delegate contentOperationDidFinish:strongContentOperationA];
        return YES;
    };
    
    __block NSUInteger contentOperationBRequestCount = 0;
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        contentOperationBRequestCount++;
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationBRequestCount, 1u);
}

- (void)testSynchronousContentOperationDoesNotCallDelegateTwice
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperation) weakContentOperation = contentOperation;
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperation) strongContentOperation = weakContentOperation;
        [strongContentOperation.delegate contentOperationDidFinish:strongContentOperation];
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, nil);
    XCTAssertEqual(self.didLoadViewModelErrorCount, 0u);
    XCTAssertEqual(self.didLoadViewModelCount, 1u);
}

- (void)testSynchronousContentOperationCallingErrorCallback
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __weak __typeof(contentOperation) weakContentOperation = contentOperation;
    NSError * const error = [NSError errorWithDomain:@"domain" code:5 userInfo:nil];
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        __strong __typeof(contentOperation) strongContentOperation = weakContentOperation;
        [strongContentOperation.delegate contentOperation:strongContentOperation didFailWithError:error];
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
    XCTAssertEqual(self.didLoadViewModelErrorCount, 1u);
    XCTAssertEqual(self.didLoadViewModelCount, 0u);
}

- (void)testSubsequentlyLoadedContentNotAppendedToViewModel
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        NSString * const randomComponentIdentifier = [NSUUID UUID].UUIDString;
        [builder builderForBodyComponentModelWithIdentifier:randomComponentIdentifier].componentName = @"component";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, 1u);
    
    [self.loader loadViewModel];
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, 1u);
}

- (void)testViewModelBuilderSnapshotting
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        XCTAssertTrue(builder.isEmpty);
        
        [builder builderForBodyComponentModelWithIdentifier:@"bodyA"].title = @"A";
        [builder builderForOverlayComponentModelWithIdentifier:@"overlayA"].title = @"A";
        
        return YES;
    };
    
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        NSString * const bodyComponentIdentifier = @"bodyB";
        NSString * const overlayComponentIdentifier = @"overlayB";
        
        XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:bodyComponentIdentifier]);
        XCTAssertFalse([builder builderExistsForOverlayComponentModelWithIdentifier:overlayComponentIdentifier]);
        
        [builder builderForBodyComponentModelWithIdentifier:bodyComponentIdentifier].title = @"B";
        [builder builderForOverlayComponentModelWithIdentifier:overlayComponentIdentifier].title = @"B";
        
        return YES;
    };
    
    HUBContentOperationMock * const contentOperationC = [HUBContentOperationMock new];
    contentOperationC.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        NSString * const bodyComponentIdentifier = @"bodyC";
        NSString * const overlayComponentIdentifier = @"overlayC";
        
        XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:bodyComponentIdentifier]);
        XCTAssertFalse([builder builderExistsForOverlayComponentModelWithIdentifier:overlayComponentIdentifier]);
        
        [builder builderForBodyComponentModelWithIdentifier:bodyComponentIdentifier].title = @"C";
        [builder builderForOverlayComponentModelWithIdentifier:overlayComponentIdentifier].title = @"C";
        
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB, contentOperationC]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationA.performCount, 1u);
    XCTAssertEqual(contentOperationB.performCount, 1u);
    XCTAssertEqual(contentOperationC.performCount, 1u);
    
    [contentOperationA.delegate contentOperationRequiresRescheduling:contentOperationA];
    
    XCTAssertEqual(contentOperationA.performCount, 2u);
    XCTAssertEqual(contentOperationB.performCount, 2u);
    XCTAssertEqual(contentOperationC.performCount, 2u);
    
    [contentOperationB.delegate contentOperationRequiresRescheduling:contentOperationB];
    
    XCTAssertEqual(contentOperationA.performCount, 2u);
    XCTAssertEqual(contentOperationB.performCount, 3u);
    XCTAssertEqual(contentOperationC.performCount, 3u);
    
    [contentOperationC.delegate contentOperationRequiresRescheduling:contentOperationC];
    
    XCTAssertEqual(contentOperationA.performCount, 2u);
    XCTAssertEqual(contentOperationB.performCount, 3u);
    XCTAssertEqual(contentOperationC.performCount, 4u);
}

- (void)testErrorSnapshotting
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationC = [HUBContentOperationMock new];
    
    NSError * const errorA = [NSError errorWithDomain:@"A" code:9 userInfo:nil];
    contentOperationA.error = errorA;
    
    NSError * const errorB = [NSError errorWithDomain:@"B" code:9 userInfo:nil];
    contentOperationB.error = errorB;
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB, contentOperationC]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqualObjects(contentOperationB.previousContentOperationError, errorA);
    XCTAssertEqualObjects(contentOperationC.previousContentOperationError, errorB);
    
    [contentOperationB.delegate contentOperationRequiresRescheduling:contentOperationB];
    
    XCTAssertEqualObjects(contentOperationB.previousContentOperationError, errorA);
    XCTAssertEqualObjects(contentOperationC.previousContentOperationError, errorB);
    
    [contentOperationC.delegate contentOperationRequiresRescheduling:contentOperationC];
    
    XCTAssertEqualObjects(contentOperationC.previousContentOperationError, errorB);
    
    contentOperationA.error = nil;
    contentOperationB.error = nil;
    
    [contentOperationA.delegate contentOperationRequiresRescheduling:contentOperationA];
    
    XCTAssertNil(contentOperationA.previousContentOperationError);
    XCTAssertNil(contentOperationB.previousContentOperationError);
    XCTAssertNil(contentOperationC.previousContentOperationError);
}

- (void)testContentOperationRescheduling
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationC = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB, contentOperationC]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperationB.delegate;
    [contentOperationDelegate contentOperationRequiresRescheduling:contentOperationB];
    [contentOperationDelegate contentOperationRequiresRescheduling:contentOperationB];
    
    XCTAssertEqual(self.didLoadViewModelCount, 3u);
    XCTAssertEqual(contentOperationA.performCount, 1u);
    XCTAssertEqual(contentOperationB.performCount, 3u);
    XCTAssertEqual(contentOperationC.performCount, 3u);
}

- (void)testErrorFromFirstContentLoadingChainNotPassedToRescheduledOperation
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSError * const error = [NSError errorWithDomain:@"domain" code:7 userInfo:nil];
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperation.delegate;
    [contentOperationDelegate contentOperation:contentOperation didFailWithError:error];
    
    XCTAssertEqual(self.errorFromFailureDelegateMethod, error);
    self.errorFromFailureDelegateMethod = nil;
    contentOperation.contentLoadingBlock = nil;
    
    [contentOperationDelegate contentOperationRequiresRescheduling:contentOperation];
    
    XCTAssertNil(contentOperation.previousContentOperationError);
    XCTAssertEqual(contentOperation.performCount, 2u);
    XCTAssertNil(self.errorFromFailureDelegateMethod);
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod);
}

- (void)testSameConnectivityStateSentToAllContentOperations
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    self.connectivityStateResolver.state = HUBConnectivityStateOffline;
    
    [contentOperationA.delegate contentOperationDidFinish:contentOperationA];
    
    XCTAssertEqual(contentOperationA.connectivityState, HUBConnectivityStateOnline);
    XCTAssertEqual(contentOperationB.connectivityState, HUBConnectivityStateOnline);
}

- (void)testConnectivityStateStartsLoadingFromBlankState
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    
    // Set reload policy to block reloads, since connectivity changes should circumvent that
    self.contentReloadPolicy.shouldReload = NO;
    
    __block NSInteger initialContentLoadingCount = 0;
    
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    contentOperationA.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        initialContentLoadingCount++;
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"initial"].title = @"Initial component";
    };
    
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    contentOperationB.contentLoadingBlock = ^BOOL(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"final"].title = @"Final component";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationA.performCount, 1u);
    XCTAssertEqual(contentOperationB.performCount, 1u);
    
    self.connectivityStateResolver.state = HUBConnectivityStateOffline;
    [self.connectivityStateResolver callObservers];
    
    XCTAssertEqual(initialContentLoadingCount, 1);
    XCTAssertEqual(contentOperationA.performCount, 2u);
    XCTAssertEqual(contentOperationB.performCount, 2u);
}

- (void)testIncorrectlyIndicatedConnectivityChangeIgnored
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperationA.performCount, 1u);
    XCTAssertEqual(contentOperationB.performCount, 1u);
    
    [self.connectivityStateResolver callObservers];
    [self.connectivityStateResolver callObservers];
    [self.connectivityStateResolver callObservers];
    [self.connectivityStateResolver callObservers];
    
    XCTAssertEqual(contentOperationA.performCount, 1u);
    XCTAssertEqual(contentOperationB.performCount, 1u);
}

- (void)testConnectivityStateChangeDoesNotStartLoadingUntilRequested
{
    self.connectivityStateResolver.state = HUBConnectivityStateOffline;

    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    contentOperationA.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"initial"].title = @"Initial component";
    };

    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    contentOperationB.contentLoadingBlock = ^BOOL(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"final"].title = @"Final component";
        return YES;
    };

    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOffline
                           initialViewModel:nil];

    self.connectivityStateResolver.state = HUBConnectivityStateOnline;
    [self.connectivityStateResolver callObservers];

    XCTAssertEqual(contentOperationA.performCount, 0u);
    XCTAssertEqual(contentOperationB.performCount, 0u);

    [self.loader loadViewModel];

    XCTAssertEqual(contentOperationA.performCount, 1u);
    XCTAssertEqual(contentOperationB.performCount, 1u);
}

- (void)testResolveConnectivityStateWhenLoading
{
    self.connectivityStateResolver.state = HUBConnectivityStateOnline;

    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    contentOperationA.initialContentLoadingBlock = ^(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"initial"].title = @"Initial component";
    };

    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    contentOperationB.contentLoadingBlock = ^BOOL(id<HUBViewModelBuilder> viewModelBuilder) {
        [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"final"].title = @"Final component";
        return YES;
    };

    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];

    self.connectivityStateResolver.state = HUBConnectivityStateOffline;
    [self.connectivityStateResolver callObservers];

    [self.loader loadViewModel];

    XCTAssertEqual(contentOperationA.connectivityState, HUBConnectivityStateOffline);
    XCTAssertEqual(contentOperationB.connectivityState, HUBConnectivityStateOffline);
}

- (void)testCorrectFeatureInfoSentToContentOperations
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNotNil(contentOperation.featureInfo);
    XCTAssertEqual(contentOperation.featureInfo, self.featureInfo);
}

- (void)testFeatureTitleAssignedAsViewTitleIfNil
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNotNil(self.viewModelFromSuccessDelegateMethod.navigationItem.title);
    XCTAssertEqualObjects(self.viewModelFromSuccessDelegateMethod.navigationItem.title,
                          self.featureInfo.title);
}

- (void)testReloadPolicyPreventingReload
{
    self.contentReloadPolicy.shouldReload = NO;
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [self.loader loadViewModel];
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperation.performCount, 1u);
}

- (void)testNilReloadPolicyAlwaysResultingInReload
{
    self.contentReloadPolicy = nil;
    
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [self.loader loadViewModel];
    [self.loader loadViewModel];
    
    XCTAssertEqual(contentOperation.performCount, 3u);
}

- (void)testAppendingPaginatedContent
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    __block id<HUBViewModelBuilder> firstViewModelBuilderA;
    __block id<HUBViewModelBuilder> firstViewModelBuilderB;
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        firstViewModelBuilderA = builder;
        [builder builderForBodyComponentModelWithIdentifier:@"A-0"].title = @"First component A";
        return YES;
    };
    
    contentOperationA.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        XCTAssertNotNil(firstViewModelBuilderA);
        XCTAssertNotNil(firstViewModelBuilderB);
        XCTAssertNotEqual(builder, firstViewModelBuilderA);
        XCTAssertNotEqual(builder, firstViewModelBuilderB);
        XCTAssertEqual(pageIndex, 1u);
        
        id<HUBComponentModelBuilder> const existingComponentModelBuilderA = [builder builderForBodyComponentModelWithIdentifier:@"A-0"];
        XCTAssertEqualObjects(existingComponentModelBuilderA.title, @"First component A");
        
        id<HUBComponentModelBuilder> const existingComponentModelBuilderB = [builder builderForBodyComponentModelWithIdentifier:@"B-0"];
        XCTAssertEqualObjects(existingComponentModelBuilderB.title, @"First component B");
        
        [builder builderForBodyComponentModelWithIdentifier:@"A-1"].title = @"Second component A";
        return YES;
    };
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        firstViewModelBuilderB = builder;
        [builder builderForBodyComponentModelWithIdentifier:@"B-0"].title = @"First component B";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    NSArray<id<HUBComponentModel>> * const componentModelsA = self.viewModelFromSuccessDelegateMethod.bodyComponentModels;
    XCTAssertEqual(componentModelsA.count, 2u);
    XCTAssertEqualObjects(componentModelsA[0].title, @"First component A");
    XCTAssertEqualObjects(componentModelsA[1].title, @"First component B");
    
    [self.loader loadNextPageForCurrentViewModel];
    
    NSArray<id<HUBComponentModel>> * const componentModelsB = self.viewModelFromSuccessDelegateMethod.bodyComponentModels;
    XCTAssertEqual(componentModelsB.count, 3u);
    XCTAssertEqualObjects(componentModelsB[0].title, @"First component A");
    XCTAssertEqualObjects(componentModelsB[1].title, @"First component B");
    XCTAssertEqualObjects(componentModelsB[2].title, @"Second component A");
}

- (void)testPageIndexIncrementedForEachPaginatedLoadingChain
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    __block NSUInteger pageIndex = 0;
    
    contentOperation.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger newPageIndex) {
        pageIndex = newPageIndex;
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    [self.loader loadNextPageForCurrentViewModel];
    XCTAssertEqual(pageIndex, 1u);
    
    [self.loader loadNextPageForCurrentViewModel];
    XCTAssertEqual(pageIndex, 2u);
    
    [self.loader loadNextPageForCurrentViewModel];
    XCTAssertEqual(pageIndex, 3u);
}

- (void)testLoadingPaginatedContentMultipleTimesAppendsToQueue
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        NSString * const componentIdentifier = [NSString stringWithFormat:@"%@", @(pageIndex)];
        [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].title = @"Component";
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperation.delegate;
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    
    // Make sure that we don't have any component models until the last operation is finished
    XCTAssertEqual(self.viewModelFromSuccessDelegateMethod.bodyComponentModels.count, 0u);
    
    // The 3rd time the delegate is called, the content loading chain is finished
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    
    NSArray<id<HUBComponentModel>> * const componentModels = self.viewModelFromSuccessDelegateMethod.bodyComponentModels;
    XCTAssertEqual(componentModels.count, 3u);
    XCTAssertEqualObjects(componentModels[0].identifier, @"1");
    XCTAssertEqualObjects(componentModels[1].identifier, @"2");
    XCTAssertEqualObjects(componentModels[2].identifier, @"3");
}

- (void)testAppendedContentOperationChaining
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        NSString * const componentIdentifier = [NSString stringWithFormat:@"A-%@", @(pageIndex)];
        [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].title = @"Component from operation A";
        return YES;
    };
    
    contentOperationB.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        NSString * const componentIdentifier = [NSString stringWithFormat:@"B-%@", @(pageIndex)];
        [builder builderForBodyComponentModelWithIdentifier:componentIdentifier].title = @"Component from operation B";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    
    NSArray<id<HUBComponentModel>> * const componentModelsA = self.viewModelFromSuccessDelegateMethod.bodyComponentModels;
    XCTAssertEqual(componentModelsA.count, 2u);
    XCTAssertEqualObjects(componentModelsA[0].identifier, @"A-1");
    XCTAssertEqualObjects(componentModelsA[1].identifier, @"B-1");
    
    [self.loader loadNextPageForCurrentViewModel];
    
    NSArray<id<HUBComponentModel>> * const componentModelsB = self.viewModelFromSuccessDelegateMethod.bodyComponentModels;
    XCTAssertEqual(componentModelsB.count, 4u);
    XCTAssertEqualObjects(componentModelsB[0].identifier, @"A-1");
    XCTAssertEqualObjects(componentModelsB[1].identifier, @"B-1");
    XCTAssertEqualObjects(componentModelsB[2].identifier, @"A-2");
    XCTAssertEqualObjects(componentModelsB[3].identifier, @"B-2");
}

- (void)testAppendedContentOperationErrorForwarding
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.error = [NSError errorWithDomain:@"A" code:15 userInfo:nil];
    contentOperationB.error = [NSError errorWithDomain:@"B" code:19 userInfo:nil];
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    
    XCTAssertNil(contentOperationA.previousContentOperationError);
    XCTAssertEqualObjects(contentOperationB.previousContentOperationError, [NSError errorWithDomain:@"A" code:15 userInfo:nil]);
    XCTAssertEqualObjects(self.errorFromFailureDelegateMethod, [NSError errorWithDomain:@"B" code:19 userInfo:nil]);
    
    [self.loader loadNextPageForCurrentViewModel];
    
    XCTAssertNil(contentOperationA.previousContentOperationError);
    XCTAssertEqualObjects(contentOperationB.previousContentOperationError, [NSError errorWithDomain:@"A" code:15 userInfo:nil]);
    XCTAssertEqualObjects(self.errorFromFailureDelegateMethod, [NSError errorWithDomain:@"B" code:19 userInfo:nil]);
}

- (void)testLoadingPaginatedContentBeforeMainContentDoesNothing
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        XCTFail(@"Should never have been called");
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    // Since we haven't called [self.loader loadViewModel] these calls should do nothing
    [self.loader loadNextPageForCurrentViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    
    XCTAssertEqual(contentOperation.performCount, 0u);
    XCTAssertNil(self.viewModelFromSuccessDelegateMethod);
}

- (void)testContentOperationReschedulingResetsAppendedContent
{
    HUBContentOperationMock * const contentOperationA = [HUBContentOperationMock new];
    HUBContentOperationMock * const contentOperationB = [HUBContentOperationMock new];
    
    contentOperationA.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        XCTAssertEqual(pageIndex, 1u);
        [builder builderForBodyComponentModelWithIdentifier:@"A-0"].title = @"Component from operation A";
        return YES;
    };
    
    contentOperationB.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        XCTAssertEqual(pageIndex, 1u);
        [builder builderForBodyComponentModelWithIdentifier:@"B-0"].title = @"Component from operation B";
        return YES;
    };
    
    [self createLoaderWithContentOperations:@[contentOperationA, contentOperationB]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    [self.loader loadViewModel];
    [self.loader loadNextPageForCurrentViewModel];
    
    contentOperationA.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        [builder builderForBodyComponentModelWithIdentifier:@"A-1"].title = @"Component from rescheduled operation A";
        return YES;
    };
    
    contentOperationB.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        [builder builderForBodyComponentModelWithIdentifier:@"B-1"].title = @"Component from rescheduled operation B";
        return YES;
    };
    
    [contentOperationA.delegate contentOperationRequiresRescheduling:contentOperationA];
    
    NSArray<id<HUBComponentModel>> * const componentModels = self.viewModelFromSuccessDelegateMethod.bodyComponentModels;
    XCTAssertEqual(componentModels.count, 2u);
    XCTAssertEqualObjects(componentModels[0].identifier, @"A-1");
    XCTAssertEqualObjects(componentModels[1].identifier, @"B-1");
}

- (void)testIsLoading
{
    HUBContentOperationMock * const contentOperation = [HUBContentOperationMock new];
    
    contentOperation.contentLoadingBlock = ^(id<HUBViewModelBuilder> builder) {
        return NO;
    };
    
    contentOperation.paginatedContentLoadingBlock = ^(id<HUBViewModelBuilder> builder, NSUInteger pageIndex) {
        return NO;
    };
    
    [self createLoaderWithContentOperations:@[contentOperation]
                          connectivityState:HUBConnectivityStateOnline
                           initialViewModel:nil];
    
    XCTAssertFalse(self.loader.isLoading);
    
    [self.loader loadViewModel];
    XCTAssertTrue(self.loader.isLoading);
    
    id<HUBContentOperationDelegate> const contentOperationDelegate = contentOperation.delegate;
    
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    XCTAssertFalse(self.loader.isLoading);
    
    [self.loader loadNextPageForCurrentViewModel];
    XCTAssertTrue(self.loader.isLoading);
    
    [contentOperationDelegate contentOperationDidFinish:contentOperation];
    XCTAssertFalse(self.loader.isLoading);
}

#pragma mark - HUBViewModelLoaderDelegate

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel
{
    XCTAssertNotNil(viewModel);
    self.viewModelFromSuccessDelegateMethod = viewModel;
    self.didLoadViewModelCount++;
}

- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error
{
    XCTAssertNotNil(error);
    self.errorFromFailureDelegateMethod = error;
    self.didLoadViewModelErrorCount++;
}

#pragma mark - Utilities

- (void)createLoaderWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                        connectivityState:(HUBConnectivityState)connectivityState
                         initialViewModel:(nullable id<HUBViewModel>)initialViewModel
{
    self.connectivityStateResolver.state = connectivityState;
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:test"];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    HUBJSONSchemaImplementation * const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                  iconImageResolver:iconImageResolver];
    
    self.loader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                                featureInfo:self.featureInfo
                                                          contentOperations:contentOperations
                                                        contentReloadPolicy:self.contentReloadPolicy
                                                                 JSONSchema:JSONSchema
                                                          componentDefaults:componentDefaults
                                                  connectivityStateResolver:self.connectivityStateResolver
                                                          iconImageResolver:iconImageResolver
                                                           initialViewModel:initialViewModel];
    
    self.loader.delegate = self;
}

@end
