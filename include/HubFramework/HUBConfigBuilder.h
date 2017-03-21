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


NS_ASSUME_NONNULL_BEGIN

@interface HUBConfigBuilder : NSObject
@property(nonatomic, nullable, strong) id<HUBJSONSchema> jsonSchema;
@property(nonatomic, nullable, strong) id<HUBContentReloadPolicy> contentReloadPolicy;
@property(nonatomic, nullable, strong) id<HUBImageLoaderFactory> imageLoaderFactory;
@property(nonatomic, nullable, strong) id<HUBConnectivityStateResolver> connectivityStateResolver;
@property(nonatomic, nullable, strong) id<HUBIconImageResolver> iconImageResolver;
@property(nonatomic, nullable, strong) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;

- (instancetype)initWithComponentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                      componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler;

- (instancetype)initWithComponentMargin:(CGFloat)componentMargin
                 componentFallbackBlock:(id<HUBComponent>(^)(HUBComponentCategory))componentFallbackBlock NS_SWIFT_NAME(init(componentMargin:componentFallbackClosure:));


- (HUBConfig *)build;

@end
NS_ASSUME_NONNULL_END


