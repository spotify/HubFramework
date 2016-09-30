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

#import "HUBManager.h"

#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBActionRegistryImplementation.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBViewControllerFactoryImplementation.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandler.h"
#import "HUBDefaultConnectivityStateResolver.h"
#import "HUBDefaultImageLoaderFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBManager ()

@property (nonatomic, strong, readonly) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistryImplementation;

@end

@implementation HUBManager

- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
{
    return [self initWithComponentLayoutManager:componentLayoutManager
                       componentFallbackHandler:componentFallbackHandler
                      connectivityStateResolver:nil
                             imageLoaderFactory:nil
                              iconImageResolver:nil
                           defaultActionHandler:nil
                     defaultContentReloadPolicy:nil
               prependedContentOperationFactory:nil
                appendedContentOperationFactory:nil];
}

- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                     connectivityStateResolver:(nullable id<HUBConnectivityStateResolver>)connectivityStateResolver
                            imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
                             iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                          defaultActionHandler:(nullable id<HUBActionHandler>)defaultActionHandler
                    defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
              prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
               appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory
{
    NSParameterAssert(componentLayoutManager != nil);
    NSParameterAssert(componentFallbackHandler != nil);
    
    self = [super init];
    
    if (self) {
        HUBComponentDefaults * const componentDefaults = [[HUBComponentDefaults alloc] initWithComponentNamespace:componentFallbackHandler.defaultComponentNamespace
                                                                                                    componentName:componentFallbackHandler.defaultComponentName
                                                                                                componentCategory:componentFallbackHandler.defaultComponentCategory];
        
        id<HUBConnectivityStateResolver> const connectivityStateResolverToUse = connectivityStateResolver ?: [HUBDefaultConnectivityStateResolver new];
        _connectivityStateResolver = connectivityStateResolverToUse;
        
        _initialViewModelRegistry = [HUBInitialViewModelRegistry new];
        
        HUBFeatureRegistryImplementation * const featureRegistry = [HUBFeatureRegistryImplementation new];
        
        HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                                              iconImageResolver:iconImageResolver];
        
        HUBComponentRegistryImplementation * const componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler
                                                                                                                         componentDefaults:componentDefaults
                                                                                                                        JSONSchemaRegistry:JSONSchemaRegistry
                                                                                                                         iconImageResolver:iconImageResolver];
        
        HUBViewModelLoaderFactoryImplementation * const viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:featureRegistry
                                                                                                                                       JSONSchemaRegistry:JSONSchemaRegistry
                                                                                                                                 initialViewModelRegistry:_initialViewModelRegistry
                                                                                                                                        componentDefaults:componentDefaults
                                                                                                                                connectivityStateResolver:_connectivityStateResolver
                                                                                                                                        iconImageResolver:iconImageResolver
                                                                                                                         prependedContentOperationFactory:prependedContentOperationFactory
                                                                                                                          appendedContentOperationFactory:appendedContentOperationFactory
                                                                                                                               defaultContentReloadPolicy:defaultContentReloadPolicy];
        
        HUBActionRegistryImplementation * const actionRegistry = [HUBActionRegistryImplementation registryWithDefaultSelectionAction];
        
        id<HUBImageLoaderFactory> const imageLoaderFactoryToUse = imageLoaderFactory ?: [HUBDefaultImageLoaderFactory new];
        
        HUBViewControllerFactoryImplementation * const viewControllerFactory = [[HUBViewControllerFactoryImplementation alloc] initWithViewModelLoaderFactory:viewModelLoaderFactory
                                                                                                                                              featureRegistry:featureRegistry
                                                                                                                                            componentRegistry:componentRegistry
                                                                                                                                     initialViewModelRegistry:_initialViewModelRegistry
                                                                                                                                               actionRegistry:actionRegistry
                                                                                                                                         defaultActionHandler:defaultActionHandler
                                                                                                                                       componentLayoutManager:componentLayoutManager
                                                                                                                                           imageLoaderFactory:imageLoaderFactoryToUse];
        
        _featureRegistry = featureRegistry;
        _componentRegistry = componentRegistry;
        _componentRegistryImplementation = componentRegistry;
        _actionRegistry = actionRegistry;
        _JSONSchemaRegistry = JSONSchemaRegistry;
        _viewModelLoaderFactory = viewModelLoaderFactory;
        _viewControllerFactory = viewControllerFactory;
    }
    
    return self;
}

#pragma mark - Accessor overrides

- (id<HUBComponentShowcaseManager>)componentShowcaseManager
{
    return self.componentRegistryImplementation;
}

@end

NS_ASSUME_NONNULL_END
