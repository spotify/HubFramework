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

#import "HUBHeaderMacros.h"
#import "HUBComponentCategories.h"
#import <CoreGraphics/CoreGraphics.h>

@protocol HUBFeatureRegistry;
@protocol HUBComponent;
@protocol HUBComponentRegistry;
@protocol HUBActionRegistry;
@protocol HUBJSONSchemaRegistry;
@protocol HUBViewModelLoaderFactory;
@protocol HUBViewControllerFactory;
@protocol HUBComponentShowcaseManager;
@protocol HUBLiveService;
@protocol HUBConnectivityStateResolver;
@protocol HUBDataLoaderFactory;
@protocol HUBImageLoaderFactory;
@protocol HUBIconImageResolver;
@protocol HUBActionHandler;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBComponentFallbackHandler;
@protocol HUBContentOperationFactory;
@protocol HUBApplicationProtocol;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class is the main entry point into the Hub Framework
 *
 *  An application using the Hub Framework should create a single instance of this class and retain it in a central
 *  location (such as its App Delegate). This class exposes the public API of the Hub Framework in a modular fashion,
 *  with each part of the API encapsulated in either a registry or a factory.
 */
@interface HUBManager : NSObject

/// The registry used to register features with the framework. See the documentation for `HUBFeatureRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBFeatureRegistry> featureRegistry;

/// The registry used to register components with the framework. See the documentation for `HUBComponentRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;

/// The registry used to register actions with the framework. See the documentation for `HUBActionRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBActionRegistry> actionRegistry;

/// The registry used to register custom JSON schemas. See the documentation for `HUBJSONSchemaRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBJSONSchemaRegistry> JSONSchemaRegistry;

/// The factory used to create view model loaders. See `HUBViewModelLoaderFactory` for more info.
@property (nonatomic, strong, readonly) id<HUBViewModelLoaderFactory> viewModelLoaderFactory;

/// The factory used to create view controllers. See `HUBViewControllerFactory` for more info.
@property (nonatomic, strong, readonly) id<HUBViewControllerFactory> viewControllerFactory;

/// The manager used to create component showcases. See `HUBComponentShowcaseManager` for more info.
@property (nonatomic, strong, readonly) id<HUBComponentShowcaseManager> componentShowcaseManager;

/// The service that can be used to enable live editing of Hub Framework-powered view controllers. Always `nil` in release builds.
@property (nonatomic, strong, readonly, nullable) id<HUBLiveService> liveService;

/**
 *  Initialize an instance of this class with all available customization options
 *
 *  @param componentLayoutManager The object to use to manage layout for components, computing margins using layout traits.
 *         See `HUBComponentLayoutManager` for more information.
 *  @param componentFallbackHandler The object to use to fall back to default components in case a component couldn't be
 *         resolved using the standard mechanism. See `HUBComponentFallbackHandler` for more information.
 *  @param connectivityStateResolver An object responsible for determining the current connectivity state of the application.
 *         If nil, a default implementation will be used, that uses the SystemConfiguration framework to determine connectivity.
 *  @param imageLoaderFactory Any custom factory that creates image loaders that are used to load remote images for components.
 *         If nil, a default image loader factory will be used. See `HUBImageLoaderFactory` for more info.
 *  @param iconImageResolver Any object responsible for converting icons into renderable images. If nil, this instance of
 *         the Hub Framework won't support icons. See `HUBIconImageResolver` for more information.
 *  @param defaultActionHandler Any default action handler to use for features that do not define their own. An action handler
 *         enables execution of custom code instead of performing an action. See `HUBActionHandler` for more information.
 *  @param defaultContentReloadPolicy Any default content reload policy to use for features that do not define their own.
 *         A content reload policy determines whenever a view belonging to the feature should have its content reloaded.
 *         If nil, any feature not defining its own reload policy will always be reloaded whenever a view that belongs to
 *         it re-appears. See `HUBContentReloadPolicy` for more information.
 *  @param prependedContentOperationFactory Any content operation factory that should be prepended to the chain of content
 *         operation factories for all views. The operations that this factory produces will therefore always be prepended
 *         to the content loading chain of any view.
 *  @param appendedContentOperationFactory Any content operation factory that should be appended to the chain of content
 *         operation factories for all views. The operations that this factory produces will therefore always be appended
 *         to the content loading chain of any view.
 *  @param application The object exposing UIApplication's properties and methods.
 *
 *  In case you don't want to use all of these customization options, see the initializers available in `HUBManager+Convenience.h`.
 */
- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                     connectivityStateResolver:(nullable id<HUBConnectivityStateResolver>)connectivityStateResolver
                            imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
                             iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                          defaultActionHandler:(nullable id<HUBActionHandler>)defaultActionHandler
                    defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
              prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
               appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory
                                   application:(id<HUBApplicationProtocol>)application HUB_DESIGNATED_INITIALIZER;

@end

/// Category providing convenience APIs for setting up a `HUBManager` instance
@interface HUBManager (Convenience)

/**
 *  Create an instance of this class with a default configuration
 *
 *  @param componentMargin The margin to use in between components. Margin will be applied between two components except
 *         when both of them are not stackable (vertical) or when one of them is full width (horizontal). For more information,
 *         see the "Layout programming guide".
 *  @param application The object exposing UIApplication's properties and methods.
 *  @param componentFallbackBlock A block that should return a fallback component in case one couldn't be resolved for a given
 *         component model. The block must always return a `HUBComponent` instance.
 *
 *  This is the easiest way to setup the Hub Framework in an application. For more customization options, see this class'
 *  designated initializer. The supplied `componentMargin` will be used to implement a default `HUBComponentLayoutManager`, and
 *  the `componentFallbackBlock` will be used for a default `HUBComponentFallbackHandler`.
 */
+ (instancetype)managerWithComponentMargin:(CGFloat)componentMargin
                               application:(id<HUBApplicationProtocol>)application
                    componentFallbackBlock:(id<HUBComponent>(^)(HUBComponentCategory))componentFallbackBlock
NS_SWIFT_NAME(init(componentMargin:application:componentFallbackClosure:));

/**
 *  Create an instance of this class with its required dependencies
 *
 *  @param componentLayoutManager The object to use to manage layout for components, computing margins using layout traits.
 *         See `HUBComponentLayoutManager` for more information.
 *  @param application The object exposing UIApplication's properties and methods.
 *  @param componentFallbackHandler The object to use to fall back to default components in case a component couldn't be
 *         resolved using the standard mechanism. See `HUBComponentFallbackHandler` for more information.
 *
 *  This is a convenience initializer, to enable you to easily setup this class with the least amount of dependencies.
 *  For more customization options, see this class' designated initializer.
 */
+ (instancetype)managerWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                                      application:(id<HUBApplicationProtocol>)application
                         componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler;

@end


NS_ASSUME_NONNULL_END
