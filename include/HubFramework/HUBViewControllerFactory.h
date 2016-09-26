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
@protocol HUBViewControllerFactory <NSObject>

/**
 *  Return whether the factory is able to create a view controller for a given view URI
 *
 *  @param viewURI The view URI to check if a view controller can be created for
 *
 *  You can use this API to validate view URIs before starting to create a view controller for them.
 */
- (BOOL)canCreateViewControllerForViewURI:(NSURL *)viewURI;

/**
 *  Create a view controller for a certain view URI
 *
 *  @param viewURI The view URI to create a view controller for
 *
 *  @return A Hub Framework-powered view controller used for rendering content provided by a feature’s
 *  content operations, using a User Interface consisting of `HUBComponent` views. If a view controller
 *  could not be created for the supplied viewURI (because a feature registration could not be resolved
 *  for it), this method returns `nil`.
 */
- (nullable UIViewController<HUBViewController> *)createViewControllerForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
