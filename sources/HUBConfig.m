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
#import "HUBConfig+Internal.h"
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

@property(nonatomic, readwrite, strong) id<HUBJSONSchema> jsonSchema;                                // For view model loader
@property(nonatomic, readwrite, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property(nonatomic, readwrite, strong) id<HUBComponentRegistry> componentRegistry;
@property(nonatomic, readwrite, strong) id<HUBImageLoaderFactory> imageLoaderFactory;
@property(nonatomic, nullable, readwrite, strong) id<HUBContentReloadPolicy> contentReloadPolicy;              // For view model loader
@property(nonatomic, nullable, readwrite, strong) id<HUBIconImageResolver> iconImageResolver;                  // For the view model loader
@property(nonatomic, nullable, readwrite, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;
@end

@implementation HUBConfig
{
    HUBComponentRegistryImplementation * _componentRegistry;
    HUBActionRegistryImplementation *_actionRegistry;
}

- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                             componentDefaults:(HUBComponentDefaults *)componentDefaults
                                    jsonSchema:(id<HUBJSONSchema>)jsonSchema
                            imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                     connectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                                actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                           contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
                             iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                   viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler
{
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(componentFallbackHandler != nil);
    NSParameterAssert(componentDefaults != nil);
    NSParameterAssert(jsonSchema != nil);
    NSParameterAssert(imageLoaderFactory != nil);
    NSParameterAssert(connectivityStateResolver != nil);
    NSParameterAssert(actionRegistry != nil);
    NSParameterAssert(componentRegistry != nil);

    self = [super init];
    if (self) {
        _componentFallbackHandler = componentFallbackHandler;
        _componentLayoutManager = componentLayoutManager;
        _componentDefaults = componentDefaults;
        _jsonSchema = jsonSchema;
        _imageLoaderFactory = imageLoaderFactory;
        _connectivityStateResolver = connectivityStateResolver;
        _actionRegistry = actionRegistry;
        _componentRegistry = componentRegistry;
        _contentReloadPolicy = contentReloadPolicy;
        _iconImageResolver = iconImageResolver;
        _viewControllerScrollHandler = viewControllerScrollHandler;
    }

    return self;
}

@end

NS_ASSUME_NONNULL_END
