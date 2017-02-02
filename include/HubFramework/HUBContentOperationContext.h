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

#import "HUBConnectivityState.h"

@protocol HUBFeatureInfo;
@protocol HUBViewModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a content operation context
 *
 *  This API is currently only used with `HUBBlockContentOperation`. For more information
 *  about the properties that are part of this API, refer to `HUBContentOperation`, or to
 *  the "Content programming guide".
 */
@protocol HUBContentOperationContext

/// The URI of the view that the content operation is being used in
@property (nonatomic, copy, readonly) NSURL *viewURI;

/// An object containing information about the feature that the operation is being used in
@property (nonatomic, strong, readonly) id<HUBFeatureInfo> featureInfo;

/// The current connectivity state, as resolved by `HUBConnectivityStateResolver`
@property (nonatomic, assign, readonly) HUBConnectivityState connectivityState;

/// The builder that can be used to add, change or remove content to/from the view
@property (nonatomic, strong, readonly) id<HUBViewModelBuilder> viewModelBuilder;

/// Any error encountered by a previous content operation in the view's content loading chain
@property (nonatomic, strong, readonly, nullable) NSError *previousError;

@end

NS_ASSUME_NONNULL_END
