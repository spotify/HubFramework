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

#import "HUBActionHandler.h"
#import "HUBHeaderMacros.h"

@class HUBActionHandlerWrapper;
@class HUBIdentifier;
@class HUBActionRegistryImplementation;
@class HUBInitialViewModelRegistry;
@class HUBViewModelLoaderImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Class handling actions for a Hub Framework powered-view, while wrapping any user-specified action handler
@interface HUBActionHandlerWrapper : NSObject <HUBActionHandler>

/**
 *  Initialize an instance of this class
 *
 *  @param actionHandler Any user-specified (either when setting up `HUBManager` or from a feature registration)
 *         action handler that this one should wrap.
 *  @param actionRegistry The registry to use to create actions
 *  @param initialViewModelRegistry The registry to use to get and set initial view models
 *  @param viewModelLoader The loader that will be used to load view models for the view that this handler is for
 */
- (instancetype)initWithActionHandler:(nullable id<HUBActionHandler>)actionHandler
                       actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
             initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      viewModelLoader:(HUBViewModelLoaderImplementation *)viewModelLoader HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
