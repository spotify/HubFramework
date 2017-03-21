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

#import "HUBSimpleViewControllerFactory.h"

#import "HUBFeatureInfoImplementation.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBConfig+Internal.h"
#import "HUBViewModelRenderer.h"
#import "HUBComponentReusePool.h"
#import "HUBActionHandlerWrapper.h"
#import "HUBCollectionViewFactory.h"
#import "HUBViewControllerDefaultScrollHandler.h"
#import "HUBImageLoader.h"
#import "HUBImageLoaderFactory.h"
#import "HUBViewController+Initializer.h"


@implementation HUBSimpleViewControllerFactory

- (HUBViewController *)createViewControllerWithConfig:(HUBConfig *)config
                                    contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                                              viewURI:(NSURL *)viewURI
                                    featureIdentifier:(NSString *)featureIdentifier
                                         featureTitle:(NSString *)featureTitle
                                        actionHandler:(nullable id<HUBActionHandler>)actionHandler
{
    id<HUBFeatureInfo> const featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:featureIdentifier
                                                                                              title:featureTitle];

    HUBViewModelLoaderImplementation * const viewModelLoader = [[HUBViewModelLoaderImplementation alloc] initWithViewURI:viewURI
                                                                                                             featureInfo:featureInfo
                                                                                                       contentOperations:contentOperations
                                                                                                     contentReloadPolicy:config.contentReloadPolicy
                                                                                                              JSONSchema:config.jsonSchema
                                                                                                       componentDefaults:config.componentDefaults
                                                                                               connectivityStateResolver:config.connectivityStateResolver
                                                                                                       iconImageResolver:config.iconImageResolver
                                                                                                        initialViewModel:nil];


    HUBViewModelRenderer * const viewModelRenderer = [HUBViewModelRenderer new];
    HUBCollectionViewFactory * const collectionViewFactory = [HUBCollectionViewFactory new];
    HUBComponentReusePool * const componentReusePool = [[HUBComponentReusePool alloc] initWithComponentRegistry:config.componentRegistry];

    id<HUBActionHandler> const actionHandlerWrapper = [[HUBActionHandlerWrapper alloc] initWithActionHandler:actionHandler
                                                                                              actionRegistry:config.actionRegistry
                                                                                    initialViewModelRegistry:nil
                                                                                             viewModelLoader:viewModelLoader];
    id<HUBViewControllerScrollHandler> const scrollHandlerToUse = config.viewControllerScrollHandler ?: [HUBViewControllerDefaultScrollHandler new];

    id<HUBImageLoader> const imageLoader = [config.imageLoaderFactory createImageLoader];

    return [[HUBViewController alloc] initWithViewURI:viewURI
                                          featureInfo:featureInfo
                                      viewModelLoader:viewModelLoader
                                    viewModelRenderer:viewModelRenderer
                                collectionViewFactory:collectionViewFactory
                                    componentRegistry:config.componentRegistry
                                   componentReusePool:componentReusePool
                               componentLayoutManager:config.componentLayoutManager
                                        actionHandler:actionHandlerWrapper
                                        scrollHandler:scrollHandlerToUse
                                          imageLoader:imageLoader];
    
}

@end
