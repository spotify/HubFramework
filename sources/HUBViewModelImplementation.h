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

#import "HUBAutoEquatable.h"
#import "HUBViewModel.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModel` API
@interface HUBViewModelImplementation : HUBAutoEquatable <HUBViewModel>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier The identifier of the view
 *  @param navigationItem Any navigation item that should be used for the view's controller
 *  @param headerComponentModel The model for any component that make up the view's header
 *  @param bodyComponentModels The models for the components that make up the view's body
 *  @param overlayComponentModels The models for the components that will be rendered as overlays
 *  @param extensionURL Any HTTP URL from which data can be downloaded to extend this view model
 *  @param customData Any custom data that should be associated with the view
 */
- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                    navigationItem:(nullable UINavigationItem *)navigationItem
              headerComponentModel:(nullable id<HUBComponentModel>)headerComponentModel
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
            overlayComponentModels:(NSArray<id<HUBComponentModel>> *)overlayComponentModels
                      extensionURL:(nullable NSURL *)extensionURL
                        customData:(nullable NSDictionary<NSString *, id> *)customData HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
