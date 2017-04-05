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

#import "HUBConfig+Testing.h"
#import "HUBConfigBuilder.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBImageLoaderFactoryMock.h"
#import "HUBIconImageResolverMock.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBViewControllerScrollHandlerMock.h"

@implementation HUBConfig(Testing)

+ (HUBConfig *)configForTesting
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];

    HUBConfigBuilder * const builder = [[HUBConfigBuilder alloc] initWithComponentLayoutManager:componentLayoutManager
                                                                       componentFallbackHandler:componentFallbackHandler];

    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBJSONSchema> const jsonSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                      iconImageResolver:iconImageResolver];
    id<HUBContentReloadPolicy> const contentReloadPolicy = [HUBContentReloadPolicyMock new];
    id<HUBImageLoaderFactory> const imageLoaderFactory = [HUBImageLoaderFactoryMock new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBViewControllerScrollHandler> const viewControllerScrollHandler = [HUBViewControllerScrollHandlerMock new];

    builder.jsonSchema = jsonSchema;
    builder.contentReloadPolicy = contentReloadPolicy;
    builder.imageLoaderFactory = imageLoaderFactory;
    builder.connectivityStateResolver = connectivityStateResolver;
    builder.iconImageResolver = iconImageResolver;
    builder.viewControllerScrollHandler = viewControllerScrollHandler;

    return [builder build];
}

@end
