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

@protocol HUBActionRegistry;
@protocol HUBJSONSchema;
@protocol HUBComponentFallbackHandler;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBImageLoaderFactory;
@protocol HUBConnectivityStateResolver;
@protocol HUBIconImageResolver;
@protocol HUBViewControllerScrollHandler;
@protocol HUBComponentRegistry;


NS_ASSUME_NONNULL_BEGIN

/**
 *  Configuration used to create view controllers when using Hub Framework without `HUBManager`.
 *
 *  A `HUBConfig` is not created directly but built through the `HUBConfigBuilder`.
 *
 *  This allows for using Hub Framework without the `HubManager` and feature registration.
 *
 */
@interface HUBConfig : NSObject
/// The object to use to manage layout for components, computing margins using layout traits.
/// See `HUBComponentLayoutManager` for more information.
@property(nonatomic, readonly, strong) id<HUBComponentLayoutManager> componentLayoutManager;

/// The object to use to fall back to default components in case a component couldn't be resolved using the standard mechanism.
/// See `HUBComponentFallbackHandler` for more information.
@property(nonatomic, readonly, strong) id<HUBComponentFallbackHandler> componentFallbackHandler;

/// JSON schema used for this configuration.
@property(nonatomic, readonly, strong) id<HUBJSONSchema> jsonSchema;

/// A factory that creates image loaders that are used to load remote images for components. See `HUBImageLoaderFactory` for more info.
@property(nonatomic, readonly, strong) id<HUBImageLoaderFactory> imageLoaderFactory;

/// An object responsible for determining the current connectivity state of the application.
@property(nonatomic, readonly, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;

/// A content reload policy determines whenever a view should have its content reloaded. If `nil`, it will always be reloaded
/// when the view re-appears. See `HUBContentReloadPolicy` for more information.
@property(nonatomic, nullable, readonly, strong) id<HUBContentReloadPolicy> contentReloadPolicy;

/// An object responsible for converting icons into renderable images. If nil, this configuration won't support icons. See
/// `HUBIconImageResolver` for more information.
@property(nonatomic, nullable, readonly, strong) id<HUBIconImageResolver> iconImageResolver;

/// A custom scroll handler to use to handle scroll events and customize scrolling behavior of view controllers created with this
/// configuration. See `HUBViewControllerScrollHandler` for more info.
@property(nonatomic, nullable, readonly, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;

/// The registry used to register actions with the framework. See the documentation for `HUBFeatureRegistry` for more info.
@property(nonatomic, readonly, strong) id<HUBActionRegistry> actionRegistry;

/// The registry used to register components with the framework. See the documentation for `HUBComponentRegistry` for more info.
@property(nonatomic, readonly, strong) id<HUBComponentRegistry> componentRegistry;

/// Use `HUBConfigBuilder` to create instances of this class
+ (instancetype)new NS_UNAVAILABLE;

/// Use `HUBConfigBuilder` to create instances of this class
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
