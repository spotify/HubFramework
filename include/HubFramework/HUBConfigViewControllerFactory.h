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

@class HUBConfig;
@class HUBViewController;
@protocol HUBActionHandler;
@protocol HUBContentOperation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `HUBViewController` factory that uses a `HUBConfig` for all the configuration needed to create a view controller.
 *
 *  This view controller allows for a fully configured `HUBViewController` to be created without going through the 
 *  `HUBManager` and `HUBFeatureRegistration`.
 */
@interface HUBConfigViewControllerFactory : NSObject

/**
 *  Creates a view controller based on the `config` passed to it.
 *
 *  @param config The configuration used to setup the view controller.
 *  @param contentOperations Content operations to load data for the created view controller.
 *         See `HUBContentOperation` and "Content Programming Guide" for more information.
 *  @param viewURI Used to set the `viewURI` on the created view controller.
 *  @param featureIdentifier Used to set the `featureInfo` on the created view controller.
 *  @param featureTitle Used to set the `featureInfo` on the created view controller.
 *  @param actionHandler Optional custom action handler. See `HUBActionHandler` for more info.
 */
- (HUBViewController *)createViewControllerWithConfig:(HUBConfig *)config
                                    contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                                              viewURI:(NSURL *)viewURI
                                    featureIdentifier:(NSString *)featureIdentifier
                                         featureTitle:(NSString *)featureTitle
                                        actionHandler:(nullable id<HUBActionHandler>)actionHandler;

@end

NS_ASSUME_NONNULL_END
