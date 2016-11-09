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

#import "HUBContentOperationWithInitialContent.h"
#import "HUBContentOperationWithPaginatedContent.h"
#import "HUBContentOperationActionObserver.h"
#import "HUBContentOperationActionPerformer.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content operation, for use in tests only
@interface HUBContentOperationMock : NSObject <
    HUBContentOperationWithInitialContent,
    HUBContentOperationWithPaginatedContent,
    HUBContentOperationActionObserver,
    HUBContentOperationActionPerformer
>

/// A block that gets called whenever the content operation is asked to add initial content to a view model builder.
@property (nonatomic, copy, nullable) void(^initialContentLoadingBlock)(id<HUBViewModelBuilder> builder);

/// A block that gets called whenever the content operation is performed. Return whether the operation should call its delegate.
@property (nonatomic, copy, nullable) BOOL(^contentLoadingBlock)(id<HUBViewModelBuilder> builder);

/**
 *  A block that gets called whenever the content operation is asked to load paginated content
 *
 *  If nil, the content operation will act like it's not conforming to the `HUBContentOperationWithPaginatedContent` protocol.
 *  Setting this to non-nil will enable the paginated content API on this mock.
 *
 *  Any block assigned to this property takes the current view model builder, as well as the current page index, and should return
 *  whether the operation should call its delegate
 */
@property (nonatomic, copy, nullable) BOOL(^paginatedContentLoadingBlock)(id<HUBViewModelBuilder> builder, NSUInteger pageIndex);

/// The number of times this operation has been performed (not including appending paginated content)
@property (nonatomic, assign, readonly) NSUInteger performCount;

/// The feature info that was most recently sent to this operation
@property (nonatomic, strong, readonly) id<HUBFeatureInfo> featureInfo;

/// The connectivity state that was most recently sent to this operation
@property (nonatomic, assign, readonly) HUBConnectivityState connectivityState;

/// Any previous content operation error that was passed to this content operation
@property (nonatomic, strong, readonly, nullable) NSError *previousContentOperationError;

/// Any action context that was most recently sent to this operation
@property (nonatomic, strong, readonly, nullable) id<HUBActionContext> actionContext;

/// Any error that the content operation should always produce
@property (nonatomic, strong, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END
