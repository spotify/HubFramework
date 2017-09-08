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

#import <UIKIt/UIKit.h>

@protocol HUBViewController;
@protocol HUBContentOperation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a factory that creates view controllers
 *
 *  You don’t conform to this protocol yourself. Instead, access this API through the application’s
 *  `HUBManager`. You use this API to create view controllers that are powered by the Hub Framework,
 *  somewhere in your navigation code, where new view controllers should be pushed. Since the Hub
 *  Framework uses URL-based navigation (per default), a recommended place to create view controllers
 *  using this factory, would be when you are responding to opening URLs, for example in your App Delegate.
 */
@protocol HUBViewControllerFactory

/**
 *  Return whether the factory is able to create a view controller for a given view URI
 *
 *  @param viewURI The view URI to check if a view controller can be created for
 *
 *  You can use this API to validate view URIs before starting to create a view controller for them.
 */
- (BOOL)canCreateViewControllerForViewURI:(NSURL *)viewURI;

/**
 *  Create a view controller for a certain pre-registered view URI
 *
 *  @param viewURI The view URI to create a view controller for. The URI should match a feature that
 *         was previously registered with `HUBFeatureRegistry`.
 *
 *  @return A Hub Framework-powered view controller used for rendering content provided by a feature’s
 *  content operations, using a User Interface consisting of `HUBComponent` views. If a view controller
 *  could not be created for the supplied viewURI (because a feature registration could not be resolved
 *  for it), this method returns `nil`.
 *
 *  To be able to create a view controller without creating a feature, you can use the other view controller
 *  creation methods available on this protocol.
 */
- (nullable id<HUBViewController>)createViewControllerForViewURI:(NSURL *)viewURI;

/**
 *  Create a view controller without a feature registration, with implicit identifiers
 *
 *  @param contentOperations The content operations to use to load the content for the view controller.
 *  @param featureTitle The title of the feature that the view controller will belong to. Used for its
 *         default title, and also made available to content operations as part of `HUBFeatureInfo`.
 *
 *  The view controller's feature identifier and view URI will be set by transforming the given feature
 *  title into lowercase characters.
 */
- (id<HUBViewController>)createViewControllerWithContentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                                                    featureTitle:(NSString *)featureTitle NS_SWIFT_NAME(createViewController(withContentOperations:featureTitle:));

/**
 *  Create a view controller without a feature registration, with explicit identifiers
 *
 *  @param viewURI The URI of the view controller to create. This view URI will not be looked up in the
 *         Hub Framework's feature registry, it will simply be assigned to the view controller.
 *  @param contentOperations The content operations to use to load the content for the view controller.
 *  @param featureIdentifier The identifier of the feature that the view controller will belong to. Will
 *         be made available to content operations as part of `HUBFeatureInfo`.
 *  @param featureTitle The title of the feature that the view controller will belong to. Used for its
 *         default title, and also made available to contnet operations as part of `HUBFeatureInfo`.
 */
- (id<HUBViewController>)createViewControllerForViewURI:(NSURL *)viewURI
                                    contentOperations:(NSArray<id<HUBContentOperation>> *)contentOperations
                                    featureIdentifier:(NSString *)featureIdentifier
                                         featureTitle:(NSString *)featureTitle;

@end

NS_ASSUME_NONNULL_END
