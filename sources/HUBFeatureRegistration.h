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

@protocol HUBContentOperationFactory;
@protocol HUBContentReloadPolicy;
@protocol HUBActionHandler;
@protocol HUBViewControllerScrollHandler;
@class HUBViewURIPredicate;

NS_ASSUME_NONNULL_BEGIN

/// Model object representing a feature registered with the Hub Framework
@interface HUBFeatureRegistration : NSObject

/// The identifier of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/// The localized title of the feature that this registration is for
@property (nonatomic, copy, readonly) NSString *featureTitle;

/// The view URI predicate that the feature will use
@property (nonatomic, strong, readonly) HUBViewURIPredicate *viewURIPredicate;

/// The content operation factories that the feature is using
@property (nonatomic, strong, readonly) NSArray<id<HUBContentOperationFactory>> *contentOperationFactories;

/// Any custom content reload policy that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBContentReloadPolicy> contentReloadPolicy;

/// The identifier of any custom JSON schema that the feature is using
@property (nonatomic, copy, nullable, readonly) NSString *customJSONSchemaIdentifier;

/// Any custom action handler that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBActionHandler> actionHandler;

/// Any custom view controller scroll handler that the feature is using
@property (nonatomic, strong, nullable, readonly) id<HUBViewControllerScrollHandler> viewControllerScrollHandler;

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param featureIdentifier The identifier of the feature
 *  @param featureTitle The localized title of the feature
 *  @param viewURIPredicate The view URI predicate that the feature will use
 *  @param contentOperationFactories The content operation factories that the feature will use
 *  @param contentReloadPolicy Any custom content reload policy that the feature will use
 *  @param customJSONSchemaIdentifier The identifier of any custom JSON schema the feature will use
 *  @param actionHandler Any custom action handler that the feature will use
 *  @param viewControllerScrollHandler Any custom view controller scroll handler that the feature will use
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                                    title:(NSString *)featureTitle
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                            actionHandler:(nullable id<HUBActionHandler>)actionHandler
              viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
