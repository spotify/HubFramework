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

@protocol HUBComponent;


NS_ASSUME_NONNULL_BEGIN

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


@protocol HUBConfigOptions
@property(nonatomic, nullable, strong) id<HUBJSONSchema> jsonSchema;
@property(nonatomic, nullable, strong) id<HUBContentReloadPolicy> contentReloadPolicy;
@property(nonatomic, nullable, strong) id<HUBImageLoaderFactory> imageLoaderFactory;
@property(nonatomic, nullable, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property(nonatomic, nullable, strong) id<HUBIconImageResolver> iconImageResolver;
@property(nonatomic, nullable, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;
@end

@interface HUBConfig : NSObject
@property(nonatomic, readonly, strong) id<HUBComponentLayoutManager> componentLayoutManager;
@property(nonatomic, readonly, strong) id<HUBComponentFallbackHandler> componentFallbackHandler;
@property(nonatomic, readonly, strong) id<HUBJSONSchema> jsonSchema;
@property(nonatomic, readonly, strong) id<HUBImageLoaderFactory> imageLoaderFactory;
@property(nonatomic, readonly, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property(nonatomic, nullable, readonly, strong) id<HUBContentReloadPolicy> contentReloadPolicy;
@property(nonatomic, nullable, readonly, strong) id<HUBIconImageResolver> iconImageResolver;
@property(nonatomic, nullable, readonly, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;
@property(nonatomic, readonly, strong) id<HUBActionRegistry> actionRegistry;
@property(nonatomic, readonly, strong) id<HUBComponentRegistry> componentRegistry;

+ (instancetype)buildConfigWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                             componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                                         optionsBlock:(void (^__nullable)(id<HUBConfigOptions>))block;

+ (instancetype)buildConfigWithComponentMargin:(CGFloat)componentMargin
                        componentFallbackBlock:(id<HUBComponent>(^)(HUBComponentCategory))componentFallbackBlock
                                  optionsBlock:(void (^__nullable)(id<HUBConfigOptions>))block NS_SWIFT_NAME(build(componentMargin:componentFallbackClosure:optionsClosure:));

@end

NS_ASSUME_NONNULL_END
