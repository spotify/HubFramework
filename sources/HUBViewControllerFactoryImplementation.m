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

#import "HUBViewControllerFactoryImplementation.h"

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentReusePool.h"
#import "HUBImageLoaderFactory.h"
#import "HUBFeatureRegistration.h"
#import "HUBFeatureInfoImplementation.h"
#import "HUBViewControllerImplementation.h"
#import "HUBCollectionViewFactory.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBViewControllerDefaultScrollHandler.h"
#import "HUBActionHandlerWrapper.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBViewModelRenderer.h"
#import "HUBViewURIPredicate.h"
#import "HUBBlockContentOperationFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerFactoryImplementation ()

@property (nonatomic, strong, readonly) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;
@property (nonatomic, strong, readonly) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBActionRegistryImplementation *actionRegistry;
@property (nonatomic, strong, readonly, nullable) id<HUBActionHandler> defaultActionHandler;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly, nullable) id<HUBImageLoaderFactory> imageLoaderFactory;

@end

@implementation HUBViewControllerFactoryImplementation

- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                               featureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                                actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
                          defaultActionHandler:(nullable id<HUBActionHandler>)defaultActionHandler
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                            imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
{
    NSParameterAssert(viewModelLoaderFactory != nil);
    NSParameterAssert(featureRegistry != nil);
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(initialViewModelRegistry != nil);
    NSParameterAssert(actionRegistry != nil);
    NSParameterAssert(componentLayoutManager != nil);
    
    self = [super init];
    
    if (self) {
        _viewModelLoaderFactory = viewModelLoaderFactory;
        _featureRegistry = featureRegistry;
        _componentRegistry = componentRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _actionRegistry = actionRegistry;
        _defaultActionHandler = defaultActionHandler;
        _componentLayoutManager = componentLayoutManager;
        _imageLoaderFactory = imageLoaderFactory;
    }
    
    return self;
}

#pragma mark - HUBViewControllerFactory

- (BOOL)canCreateViewControllerForViewURI:(NSURL *)viewURI
{
    return [self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI];
}

- (nullable HUBViewController *)createViewControllerForViewURI:(NSURL *)viewURI
{
    HUBFeatureRegistration * const featureRegistration = [self.featureRegistry featureRegistrationForViewURI:viewURI];
    
    if (featureRegistration == nil) {
        return nil;
    }
    
    return [self createViewControllerForViewURI:viewURI featureRegistration:featureRegistration];
}

- (HUBViewController *)createViewControllerWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                                                    featureTitle:(NSString *)featureTitle
{
    NSString * const identifier = [featureTitle lowercaseString];
    NSURL * const viewURI = [NSURL URLWithString:identifier];
    
    return [self createViewControllerForViewURI:viewURI
                              contentOperations:contentOperations
                              featureIdentifier:identifier
                                   featureTitle:featureTitle];
}

- (HUBViewController *)createViewControllerForViewURI:(NSURL *)viewURI
                                    contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                                    featureIdentifier:(NSString *)featureIdentifier
                                         featureTitle:(NSString *)featureTitle
{
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    id<HUBContentOperationFactory> const contentOperationFactory = [[HUBBlockContentOperationFactory alloc] initWithBlock:^NSArray<id<HUBContentOperation>> *(NSURL *_) {
        return contentOperations;
    }];
    
    HUBFeatureRegistration * const featureRegistration = [[HUBFeatureRegistration alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                             title:featureTitle
                                                                                                  viewURIPredicate:viewURIPredicate
                                                                                         contentOperationFactories:@[contentOperationFactory]
                                                                                               contentReloadPolicy:nil customJSONSchemaIdentifier:nil actionHandler:nil viewControllerScrollHandler:nil];
    
    return [self createViewControllerForViewURI:viewURI featureRegistration:featureRegistration];
}

#pragma mark - Private utilities

- (HUBViewController *)createViewControllerForViewURI:(NSURL *)viewURI
                                  featureRegistration:(HUBFeatureRegistration *)featureRegistration
{
    id<HUBFeatureInfo> const featureInfo = [[HUBFeatureInfoImplementation alloc] initWithIdentifier:featureRegistration.featureIdentifier
                                                                                              title:featureRegistration.featureTitle];
    
    HUBViewModelLoaderImplementation * const viewModelLoader = [self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI
                                                                                                        featureRegistration:featureRegistration];
    
    HUBViewModelRenderer * const viewModelRenderer = [HUBViewModelRenderer new];
    id<HUBImageLoader> const imageLoader = [self.imageLoaderFactory createImageLoader];
    HUBCollectionViewFactory * const collectionViewFactory = [HUBCollectionViewFactory new];
    HUBComponentReusePool * const componentReusePool = [[HUBComponentReusePool alloc] initWithComponentRegistry:self.componentRegistry];
    
    id<HUBActionHandler> const actionHandler = featureRegistration.actionHandler ?: self.defaultActionHandler;
    id<HUBActionHandler> const actionHandlerWrapper = [[HUBActionHandlerWrapper alloc] initWithActionHandler:actionHandler
                                                                                              actionRegistry:self.actionRegistry
                                                                                    initialViewModelRegistry:self.initialViewModelRegistry
                                                                                             viewModelLoader:viewModelLoader];
    
    id<HUBViewControllerScrollHandler> const scrollHandlerToUse = featureRegistration.viewControllerScrollHandler ?: [HUBViewControllerDefaultScrollHandler new];
    
    return [[HUBViewControllerImplementation alloc] initWithViewURI:viewURI
                                                        featureInfo:featureInfo
                                                    viewModelLoader:viewModelLoader
                                                  viewModelRenderer:viewModelRenderer
                                              collectionViewFactory:collectionViewFactory
                                                  componentRegistry:self.componentRegistry
                                                 componentReusePool:componentReusePool
                                             componentLayoutManager:self.componentLayoutManager
                                                      actionHandler:actionHandlerWrapper
                                                      scrollHandler:scrollHandlerToUse
                                                        imageLoader:imageLoader];
}

@end

NS_ASSUME_NONNULL_END
