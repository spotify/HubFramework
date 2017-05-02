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

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#import "HUBComponentCategories.h"

@class HUBConfig;
@protocol HUBActionRegistry;
@protocol HUBComponent;
@protocol HUBJSONSchema;
@protocol HUBComponentFallbackHandler;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBImageLoaderFactory;
@protocol HUBConnectivityStateResolver;
@protocol HUBIconImageResolver;
@protocol HUBViewControllerScrollHandler;
@protocol HUBComponentRegistry;
@protocol HUBAction;


NS_ASSUME_NONNULL_BEGIN

/**
 *  Builder for a `HUBConfig`.
 *
 *  All the properties are `nullable` and when the `HUBConfig` is built, a default implementation will be used for those
 *  left unset.
 */
@interface HUBConfigBuilder : NSObject
/// JSON schema used in the built configuration.
@property(nonatomic, nullable, strong) id<HUBJSONSchema> jsonSchema;

/// A content reload policy determines whenever a view should have its content reloaded. If `nil`, it will always be reloaded
/// when the view re-appears. See `HUBContentReloadPolicy` for more information.
@property(nonatomic, nullable, strong) id<HUBContentReloadPolicy> contentReloadPolicy;

/// A factory that creates image loaders that are used to load remote images for components. See `HUBImageLoaderFactory` for more info.
@property(nonatomic, nullable, strong) id<HUBImageLoaderFactory> imageLoaderFactory;

/// An object responsible for determining the current connectivity state of the application.
@property(nonatomic, nullable, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;

/// An object responsible for converting icons into renderable images. If nil, the built configuration won't support icons. See
/// `HUBIconImageResolver` for more information.
@property(nonatomic, nullable, strong) id<HUBIconImageResolver> iconImageResolver;

/// A custom scroll handler to use to handle scroll events and customize scrolling behavior of view controllers created with the
/// built configuration. See `HUBViewControllerScrollHandler` for more info.
@property(nonatomic, nullable, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;

/// An action that gets performed whenever a component is selected. If nil, a default selection action is created.
@property(nonatomic, nullable, strong) id<HUBAction> selectionAction;


/**
 *  Designated initializer with the required `HUBConfig` options set.
 *
 *  @param componentLayoutManager  The object to use to manage layout for components, computing margins using layout traits.
 *         See `HUBComponentLayoutManager` for more information.
 *  @param componentFallbackHandler The object to use to fall back to default components in case a component couldn't be
 *         resolved using the standard mechanism. See `HUBComponentFallbackHandler` for more information.
 */
- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler HUB_DESIGNATED_INITIALIZER;

/**
 *  Convenience initializer with default layout and using a block for fallback handling.
 *
 *  @param componentMargin The margin to use in between components. Margin will be applied between two components except
 *         when both of them are not stackable (vertical) or when one of them is full width (horizontal). For more information,
 *         see the "Layout programming guide".
 *  @param componentFallbackHandler The object to use to fall back to default components in case a component couldn't be
 *         resolved using the standard mechanism. See `HUBComponentFallbackHandler` for more information.
 */
- (instancetype)initWithComponentMargin:(CGFloat)componentMargin
               componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler;

/**
 *  Builds a configuration based on builder properties.
 *
 *  @return A newly created `HUBConfig`.
 */
- (HUBConfig *)build;

@end
NS_ASSUME_NONNULL_END


