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

@protocol HUBContentOperationFactory;
@protocol HUBContentReloadPolicy;
@protocol HUBActionHandler;
@protocol HUBViewControllerScrollHandler;
@class HUBViewURIPredicate;
@class HUBFeatureRegistration;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub feature registry
 *
 *  A feature is the top-level entity in the Hub Framework, that is used to ecapsulate related views into a logical group.
 *  Views that belong to the same feature share the same setup, such as a view URI predicate, content operation factories, etc.
 */
@protocol HUBFeatureRegistry <NSObject>

/**
 *  Register a feature with the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature. Used for logging & error messages. Must be unique across the app.
 *  @param viewURIPredicate The predicate that should be used to determine whether a given view URI is part of the feature.
 *         Use `HUBViewURIPredicate` to define a predicate that matches what type of view URIs your feature should handle.
 *  @param title The title of the feature. This will be sent as part of the feature info to the content operations for views
 *         created for the feature. Should be fully localized and ready to be presented in the user interface.
 *  @param contentOperationFactories The factories that should be used to create content operations for the feature's views.
 *         The order of the factories will determine the order in which the created content operations are called each time a
 *         view that is a part of the feature will load content. See `HUBContentOperationFactory` for more information.
 *  @param contentReloadPolicy Any custom content reload policy that should be used for the feature. A content reload policy
 *         determines whenever a view belonging to the feature should have its content reloaded. If `nil`, the default reload
 *         policy for this instance of the Hub Framework will be used. See `HUBContentReloadPolicy` for more information.
 *  @param customJSONSchemaIdentifier Any identifier of a custom schema to use to parse JSON data. If `nil`, the default
 *         schema will be used. Register your custom schema using `HUBJSONSchemaRegistry`. See `HUBJSONSchema` for more info.
 *  @param actionHandler Any custom action handler that should be used for the feature. If `nil`, any default action handler
 *         for this instance of the Hub Framework will be used. Action handlers can be used to run custom code instead of
 *         performing actions. See `HUBActionHandler` for more info.
 *  @param viewControllerScrollHandler Any custom scroll handler to use to handle scroll events and customize scrolling behavior
 *         of view controllers created for this feature. See `HUBViewControllerScrollHandler` for more info.
 *
 *  Registering a feature with the same identifier as one that is already registered is considered a severe error and will
 *  trigger an assert.
 */
- (void)registerFeatureWithIdentifier:(NSString *)featureIdentifier
                     viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                                title:(NSString *)title
            contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                  contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
           customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                        actionHandler:(nullable id<HUBActionHandler>)actionHandler
          viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler;


/**
 * Register a feature with the Hub Framework
 *
 * @param feature to be registered.
 *
 *  Registering a feature with the same identifier as one that is already registered is considered a severe error and will
 *  trigger an assert.
 */
- (void)registerFeature:(HUBFeatureRegistration *)feature;

/**
 *  Unregister a feature from the Hub Framework
 *
 *  @param featureIdentifier The identifier of the feature to unregister
 *
 *  After this method has been called, The Hub Framework will remove all information stored for the given identifier, and
 *  open it up to be registered again for another feature. If the given identifier does not exist, this method does nothing.
 */
- (void)unregisterFeatureWithIdentifier:(NSString *)featureIdentifier;

@end

NS_ASSUME_NONNULL_END
