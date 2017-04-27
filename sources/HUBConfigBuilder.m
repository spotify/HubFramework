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

#import "HUBConfigBuilder.h"

#import "HUBComponent.h"
#import "HUBDefaultComponentLayoutManager.h"
#import "HUBDefaultComponentFallbackHandler.h"
#import "HUBComponentDefaults.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBActionRegistryImplementation.h"
#import "HUBDefaultImageLoaderFactory.h"
#import "HUBDefaultConnectivityStateResolver.h"
#import "HUBConfig+Internal.h"
#import "HUBSelectionAction.h"


@interface HUBConfigBuilder ()
@property (nonatomic, strong) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong) id<HUBComponentFallbackHandler> componentFallbackHandler;
@end

@implementation HUBConfigBuilder

- (instancetype)initWithComponentMargin:(CGFloat)componentMargin
               componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
{
    id<HUBComponentLayoutManager> const componentLayoutManager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:componentMargin];

    return [self initWithComponentLayoutManager:componentLayoutManager
                       componentFallbackHandler:componentFallbackHandler];
}


- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
{
    self = [super init];
    if (self) {
        _componentLayoutManager = componentLayoutManager;
        _componentFallbackHandler = componentFallbackHandler;
    }

    return self;
}

- (HUBConfig *)build
{
    HUBComponentDefaults * const componentDefaults =
    [[HUBComponentDefaults alloc] initWithComponentNamespace:self.componentFallbackHandler.defaultComponentNamespace
                                               componentName:self.componentFallbackHandler.defaultComponentName
                                           componentCategory:self.componentFallbackHandler.defaultComponentCategory];

    id<HUBJSONSchema> defaultJSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                       iconImageResolver:self.iconImageResolver];
    HUBComponentRegistryImplementation *componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:self.componentFallbackHandler
                                                                                                              componentDefaults:componentDefaults
                                                                                                                     JSONSchema:defaultJSONSchema
                                                                                                              iconImageResolver:self.iconImageResolver];
    id<HUBAction> action = self.selectionAction ? self.selectionAction : [HUBSelectionAction new];
    HUBActionRegistryImplementation *actionRegistry = [[HUBActionRegistryImplementation alloc] initWithSelectionAction:action];

    id<HUBJSONSchema> jsonSchema = (id)self.jsonSchema ?: defaultJSONSchema;

    id<HUBImageLoaderFactory> imageLoaderFactory = (id)self.imageLoaderFactory ?: [HUBDefaultImageLoaderFactory new];
    id<HUBConnectivityStateResolver> connectivityStateResolver = (id)self.connectivityStateResolver ?: [HUBDefaultConnectivityStateResolver new];

    return [[HUBConfig alloc] initWithComponentLayoutManager:self.componentLayoutManager
                                    componentFallbackHandler:self.componentFallbackHandler
                                           componentDefaults:componentDefaults
                                                  jsonSchema:jsonSchema
                                          imageLoaderFactory:imageLoaderFactory
                                   connectivityStateResolver:connectivityStateResolver
                                              actionRegistry:actionRegistry
                                           componentRegistry:componentRegistry
                                         contentReloadPolicy:self.contentReloadPolicy
                                           iconImageResolver:self.iconImageResolver
                                 viewControllerScrollHandler:self.viewControllerScrollHandler];
}

@end
