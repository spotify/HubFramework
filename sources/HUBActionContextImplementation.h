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

#import "HUBActionContext.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBActionContext` protocol.
@interface HUBActionContextImplementation : NSObject <HUBActionContext>

/** 
 *  Initializes an instance of the class with the provided values.
 *
 *  @param trigger The reason that the action will be triggered
 *  @param customActionIdentifier The identifier of any custom action that this context is for
 *  @param customData Any custom data that should be passed to the action
 *  @param viewURI The URI of the view that the action is for
 *  @param viewModel The model of the view that the action is for
 *  @param componentModel The model of any component that the action is for
 *  @param viewController The view controller presenting the view that the action is for
 */
- (instancetype)initWithTrigger:(HUBActionTrigger)trigger
         customActionIdentifier:(nullable HUBIdentifier *)customActionIdentifier
                     customData:(nullable NSDictionary<NSString *, id> *)customData
                        viewURI:(NSURL *)viewURI
                      viewModel:(id<HUBViewModel>)viewModel
                 componentModel:(nullable id<HUBComponentModel>)componentModel
                 viewController:(UIViewController *)viewController HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
