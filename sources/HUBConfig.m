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

#import <Foundation/Foundation.h>

#import "HUBConfig.h"
#import "HUBConfigOptionsImplementation.h"
#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandler.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBDefaultConnectivityStateResolver.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBDefaultImageLoaderFactory.h"
#import "HUBDefaultComponentLayoutManager.h"
#import "HUBDefaultComponentFallbackHandler.h"
#import "HUBActionRegistryImplementation.h"


NS_ASSUME_NONNULL_BEGIN

@interface HUBConfig ()
@property(nonatomic, readwrite, strong) HUBComponentDefaults *componentDefaults;
@property(nonatomic, readwrite, strong) id<HUBJSONSchema> jsonSchema;                                // For view model loader
@property(nonatomic, readwrite, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property(nonatomic, readwrite, strong) id<HUBComponentRegistry> componentRegistry;
@property(nonatomic, readwrite, strong) id<HUBImageLoaderFactory> imageLoaderFactory;
@property(nonatomic, readwrite, strong) HUBActionRegistryImplementation *actionRegistry;
@property(nonatomic, nullable, readwrite, strong) id<HUBContentReloadPolicy> contentReloadPolicy;              // For view model loader
@property(nonatomic, nullable, readwrite, strong) id<HUBIconImageResolver> iconImageResolver;                  // For the view model loader
@property(nonatomic, nullable, readwrite, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;
@end

@implementation HUBConfig

+ (instancetype)buildConfigWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                             componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                                         optionsBlock:(void (^__nullable)(id<HUBConfigOptions>))block
{
    HUBConfigOptionsImplementation * const configBuilder = [HUBConfigOptionsImplementation new];
    if (block) {
        block(configBuilder);
    }

    return [[HUBConfig alloc] initWithComponentLayoutManager:componentLayoutManager
                                    componentFallbackHandler:componentFallbackHandler
                                               configBuilder:configBuilder];
}

+ (instancetype)buildConfigWithComponentMargin:(CGFloat)componentMargin
                        componentFallbackBlock:(id<HUBComponent>(^)(HUBComponentCategory))componentFallbackBlock
                                  optionsBlock:(void (^__nullable)(id<HUBConfigOptions>))optionsBlock
{
    id<HUBComponentLayoutManager> const componentLayoutManager = [[HUBDefaultComponentLayoutManager alloc] initWithMargin:componentMargin];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBDefaultComponentFallbackHandler alloc] initWithFallbackBlock:componentFallbackBlock];

    return [self buildConfigWithComponentLayoutManager:componentLayoutManager
                              componentFallbackHandler:componentFallbackHandler
                                          optionsBlock:optionsBlock];
}

- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                                 configBuilder:(HUBConfigOptionsImplementation *)configBuilder
{
    self = [super init];
    if (self) {
        _componentLayoutManager = componentLayoutManager;
        _componentFallbackHandler = componentFallbackHandler;

        HUBComponentDefaults * const componentDefaults =
        [[HUBComponentDefaults alloc] initWithComponentNamespace:componentFallbackHandler.defaultComponentNamespace
                                                   componentName:componentFallbackHandler.defaultComponentName
                                               componentCategory:componentFallbackHandler.defaultComponentCategory];
        _componentDefaults = componentDefaults;

        id<HUBJSONSchema> defaultJSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                           iconImageResolver:configBuilder.iconImageResolver];
        _componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler
                                                                               componentDefaults:componentDefaults
                                                                                      JSONSchema:defaultJSONSchema
                                                                               iconImageResolver:configBuilder.iconImageResolver];
        _actionRegistry = [HUBActionRegistryImplementation registryWithDefaultSelectionAction];
        _jsonSchema = (id)configBuilder.jsonSchema ?: defaultJSONSchema;

        _contentReloadPolicy = configBuilder.contentReloadPolicy;
        _imageLoaderFactory = (id)configBuilder.imageLoaderFactory ?: [HUBDefaultImageLoaderFactory new];

        _connectivityStateResolver = (id)configBuilder.connectivityStateResolver ?: [HUBDefaultConnectivityStateResolver new];
        _iconImageResolver = configBuilder.iconImageResolver;
        _viewControllerScrollHandler = configBuilder.viewControllerScrollHandler;
    }

    return self;
}

@end

NS_ASSUME_NONNULL_END

