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

#import "HUBConfig.h"
#import "HUBConfigBuilder.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBImageLoaderFactoryMock.h"
#import "HUBIconImageResolverMock.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBTestUtilities.h"
#import "HUBViewControllerScrollHandlerMock.h"
#import "HUBApplicationMock.h"

@interface HUBConfigTests : XCTestCase
@property(nonatomic, strong) HUBComponentDefaults *componentDefaults;
@property(nonatomic, strong) HUBComponentFallbackHandlerMock *componentFallbackHandler;
@property(nonatomic, strong) HUBComponentLayoutManagerMock *componentLayoutManager;
@end

@implementation HUBConfigTests

- (void)setUp
{
    self.componentDefaults = [HUBComponentDefaults defaultsForTesting];
    self.componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:self.componentDefaults];
    self.componentLayoutManager = [HUBComponentLayoutManagerMock new];
}


- (void)testBuilderCanCreateConfigWithNoOptionalParameters
{
    HUBConfigBuilder *builder = [[HUBConfigBuilder alloc] initWithComponentLayoutManager:self.componentLayoutManager
                                                                componentFallbackHandler:self.componentFallbackHandler];

    HUBConfig *config = [builder build];
    XCTAssertNotNil(config);
    XCTAssertEqual(config.componentLayoutManager, self.componentLayoutManager);
    XCTAssertEqual(config.componentFallbackHandler, self.componentFallbackHandler);
}

- (void)testBuilderCanCreateConfigThroughConvinienceMethod
{
    HUBConfigBuilder * const builder = [[HUBConfigBuilder alloc] initWithComponentMargin:57
                                                                componentFallbackHandler:self.componentFallbackHandler];
    HUBConfig * const config = [builder build];

    XCTAssertNotNil(config);
    id<HUBComponentLayoutManager> const layoutManager = config.componentLayoutManager;
    CGFloat margin = [layoutManager marginBetweenComponentWithLayoutTraits:[NSSet setWithObject:HUBComponentLayoutTraitCentered]
                                                            andContentEdge:HUBComponentLayoutContentEdgeTop];
    HUBAssertEqualCGFloatValues(margin, 57);
}

- (void)testBuilderCreatesDefaultConfigPropertiesWhenUndefined
{
    HUBConfigBuilder *builder = [[HUBConfigBuilder alloc] initWithComponentLayoutManager:self.componentLayoutManager
                                                                componentFallbackHandler:self.componentFallbackHandler];

    HUBConfig *config = [builder build];
    XCTAssertNotNil(config.jsonSchema);
    XCTAssertNotNil(config.imageLoaderFactory);
    XCTAssertNotNil(config.connectivityStateResolver);
}

- (void)testBuilderCreatesActionAndComponentRegistry
{
    HUBConfigBuilder *builder = [[HUBConfigBuilder alloc] initWithComponentLayoutManager:self.componentLayoutManager
                                                                componentFallbackHandler:self.componentFallbackHandler];

    HUBConfig *config = [builder build];

    XCTAssertNotNil(config.actionRegistry);
    XCTAssertNotNil(config.componentRegistry);
}

- (void)testBuilderCanCreateConfigWithOptionalValuesDefines
{
    HUBConfigBuilder * const builder = [[HUBConfigBuilder alloc] initWithComponentLayoutManager:self.componentLayoutManager
                                                                       componentFallbackHandler:self.componentFallbackHandler];


    id<HUBJSONSchema> const jsonSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults
                                                                                      iconImageResolver:nil];
    id<HUBContentReloadPolicy> const contentReloadPolicy = [HUBContentReloadPolicyMock new];
    id<HUBImageLoaderFactory> const imageLoaderFactory = [HUBImageLoaderFactoryMock new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBViewControllerScrollHandler> const viewControllerScrollHandler = [HUBViewControllerScrollHandlerMock new];

    builder.jsonSchema = jsonSchema;
    builder.contentReloadPolicy = contentReloadPolicy;
    builder.imageLoaderFactory = imageLoaderFactory;
    builder.connectivityStateResolver = connectivityStateResolver;
    builder.iconImageResolver = iconImageResolver;
    builder.viewControllerScrollHandler = viewControllerScrollHandler;

    HUBConfig * const config = [builder build];

    XCTAssertNotNil(config);
    XCTAssertEqual(jsonSchema, config.jsonSchema);
    XCTAssertEqual(contentReloadPolicy, config.contentReloadPolicy);
    XCTAssertEqual(imageLoaderFactory, config.imageLoaderFactory);
    XCTAssertEqual(connectivityStateResolver, config.connectivityStateResolver);
    XCTAssertEqual(iconImageResolver, config.iconImageResolver);
    XCTAssertEqual(viewControllerScrollHandler, config.viewControllerScrollHandler);
}

@end
