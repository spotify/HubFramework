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
@protocol HUBViewModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBViewModelLoader`
 *
 *  Conform to this protocol in a custom object to get notified when a view model was loaded, or if an
 *  error occured in the loading process.
 */
@protocol HUBViewModelLoaderDelegate <NSObject>

/**
 *  Sent to a view model loader's delegate when a view model was loaded
 *
 *  @param viewModelLoader The view model loader that loaded a view model
 *  @param viewModel The view model that was loaded
 *
 *  Note that this method might be called multiple times during a view model loader's lifecycle, as it will be
 *  called whenever a view model finished loading. This might happen either as the result of calling `loadViewModel`,
 *  whenever a content operation was rescheduled and completed, or whenever the current connectivity state was changed.
 */
- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didLoadViewModel:(id<HUBViewModel>)viewModel;

/**
 *  Sent to a view model loader's delegate when an error occured, causing the loader to fail
 *
 *  @param viewModelLoader The view model loader that encountered the error
 *  @param error The error that was encountered
 */
- (void)viewModelLoader:(id<HUBViewModelLoader>)viewModelLoader didFailLoadingWithError:(NSError *)error;

@end

/**
 *  Protocol defining the public API of a view model loader
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create objects conforming to
 *  this protocol internally. This API is currently not accessible from outside of the Hub Framework, but will
 *  be soon as part of the external data API.
 */
@protocol HUBViewModelLoader <NSObject>

/**
 *  The view model loader's delegate
 *
 *  Assign a custom object to this property to get notified of events. See `HUBViewModelLoaderDelegate` for
 *  more information.
 */
@property (nonatomic, weak, nullable) id<HUBViewModelLoaderDelegate> delegate;

/**
 *  The view model that should initially be used, before a "proper" view model has been loaded
 *
 *  Accessing this property will either return a pre-computed initial view model, or cause the loader's
 *  content operations to be asked to prepare an initial view model. The initial view model will then be cached,
 *  so it's fine to access this property multiple times.
 */
@property (nonatomic, strong, readonly) id<HUBViewModel> initialViewModel;

/**
 *  Whether the view model loader is currently loading
 *
 *  True whenever one or more content operations are currently in the process of loading content, either as part
 *  of the main content loading chain, or as part of appending paginated content.
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 *  Load a view model using this loader
 *
 *  Depending on the current connectivity state (determined by the current `HUBConnectivityStateResolver`),
 *  and the configuration of the feature that his view model is serving, a combination of remote and local
 *  content will be loaded using the respective content operations.
 *
 *  The loader will notify its delegate once the operation was completed or if it failed.
 *  See `HUBViewModelLoaderDelegate` for more information.
 */
- (void)loadViewModel;

- (void)loadViewModelRegardlessOfReloadPolicy;

/**
 *  Load the next set of paginated content for the current view model this loader is for
 *
 *  Use this method to extend the current view model with additional paginated content. The view model loader
 *  automatically manages the current state of the view and the page index for you, so all you have to do is to
 *  call this method whenever additional content should be loaded.
 *
 *  Content loaded this way will be appended to the current view model, so if it already contains 2 component
 *  models (A & B), and a new one (C) is added through this mechanism - the resulting view model will now contain
 *  A, B & C.
 *
 *  Calling this method invokes content operations conforming to `HUBContentOperationWithPaginatedContent`.
 *
 *  The same delegate methods are called for success/error when the view model loader finishes this task.
 *
 *  Calling this method before first loading a view model using `loadViewModel` does nothing.
 */
- (void)loadNextPageForCurrentViewModel;

@end

NS_ASSUME_NONNULL_END
