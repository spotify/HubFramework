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

@protocol HUBViewModelLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a factory that creates view model loaders
 *
 *  You don't conform to this protocol yourself. Instead, access this API through the application's
 *  `HUBManager`. You can use this API to create view model loaders for use outside of the Hub Framework,
 *  in case you want to use data from a Hub Framework-powered feature in a part of the app that does not
 *  use the framework.
 */
@protocol HUBViewModelLoaderFactory <NSObject>

/**
 *  Return whether the factory is able to create a view model loader for a given view URI
 *
 *  @param viewURI The view URI to check if a view model loader can be created for
 *
 *  You can use this API to validate view URIs before starting to create a view model loader for them.
 */
- (BOOL)canCreateViewModelLoaderForViewURI:(NSURL *)viewURI;

/**
 *  Create a view model loader that matches a certain view URI
 *
 *  @param viewURI The view URI to create a view model loader for
 *
 *  @return A loader that can be used to load a view model that matches the supplied view URI, or `nil`
 *  if the view URI couldn't be recognized by the Hub Framework. This method also returns `nil` (and
 *  triggers an assert) if a view model loader was requested for a feature that was not able to create
 *  any content operations.
 */
- (nullable id<HUBViewModelLoader>)createViewModelLoaderForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
