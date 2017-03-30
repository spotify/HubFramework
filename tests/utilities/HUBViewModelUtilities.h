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

#import "HUBComponentType.h"

@protocol HUBComponentModel;
@protocol HUBViewModel;
@class HUBIdentifier;

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelUtilities : NSObject


/// Creates a component model with given identifier, type, component identifier and custom data
+ (id<HUBComponentModel>)createComponentModelWithIdentifier:(NSString *)identifier
                                                       type:(HUBComponentType)type
                                        componentIdentifier:(HUBIdentifier *)componentIdentifier
                                                 customData:(nullable NSDictionary *)customData;

/// Creates a component model with the given identifier and custom data.
+ (id<HUBComponentModel>)createComponentModelWithIdentifier:(NSString *)identifier
                                                 customData:(nullable NSDictionary *)customData;

/// Creates a view model with the given identifier and body components and header component
+ (id<HUBViewModel>)createViewModelWithIdentifier:(NSString *)identifier
                                   bodyComponents:(NSArray<id<HUBComponentModel>> *)components
                                  headerComponent:(nullable id<HUBComponentModel>)headerComponent;

/// Creates a view model with the given identifier and components.
+ (id<HUBViewModel>)createViewModelWithIdentifier:(NSString *)identifier components:(NSArray<id<HUBComponentModel>> *)components;

@end

NS_ASSUME_NONNULL_END
