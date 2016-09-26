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

@protocol HUBViewModel;

NS_ASSUME_NONNULL_BEGIN

/// Registry used to keep track of initial view models for view URIs
@interface HUBInitialViewModelRegistry : NSObject

/**
 *  Register an initial view model for a view URI
 *
 *  @param initialViewModel The initial view model to register
 *  @param viewURI The view URI to register the initial view model for
 *
 *  Calling this method with a view URI for which an initial view model has already been registered
 *  will cause the old registration to be overwritten.
 */
- (void)registerInitialViewModel:(id<HUBViewModel>)initialViewModel forViewURI:(NSURL *)viewURI;

/**
 *  Remove any previously registered initial view model for a view URI
 *
 *  @param viewURI The view URI to remove an initial view model for
 */
- (void)removeInitialViewModelForViewURI:(NSURL *)viewURI;

/**
 *  Return any previously registered initial view model for a view URI
 *
 *  @param viewURI The view URI to retrieve an initial view model for
 */
- (nullable id<HUBViewModel>)initialViewModelForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
