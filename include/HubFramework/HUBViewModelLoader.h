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

@end

NS_ASSUME_NONNULL_END
