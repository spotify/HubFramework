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

#import "HUBContentOperation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended content operation protocol that adds the ability to append paginated content to a view
 *
 *  Use this protocol in case you want to handle large datasets in your feature, which are not practical
 *  to load up front. Content operations conforming to this protocol will be called and asked to append
 *  content to an existing view model builder in either of 3 scenarios:
 *
 *  - If the `loadNextPageForCurrentViewModel` method was called on a `HUBViewModelLoader`.
 *  - If the user is about to reach the bottom of the view's content when scrolling.
 */
@protocol HUBContentOperationWithPaginatedContent <HUBContentOperation>

/**
 *  Append content for a certain page index to an existing view model builder
 *
 *  @param pageIndex The index of the page to add content for. Since the main content set is considered
 *         index number 0, this will always be at least 1 or greater. Incremented on each paginated content
 *         loading chain.
 *  @param viewModelBuilder The builder to use to append content to the view. If this content operation is
 *         first in the appended content loading chain, this builder will be a snapshot of the last rendered
 *         view state. If it's subsequent in the chain, it will instead be a snapshot of the previous operation's
 *         finished state.
 *  @param viewURI The URI of the view that content should be appended for
 *  @param featureInfo Info about the feature that the operation is being performed for
 *  @param connectivityState The current connectivity state of the application (as it was when the content loading
 *         chain that this operation is part of was started).
 *  @param previousError Any previous error that was encountered during the content loading chain that this operation
 *         is a part of.
 */
- (void)appendContentForPageIndex:(NSUInteger)pageIndex
               toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
                          viewURI:(NSURL *)viewURI
                      featureInfo:(id<HUBFeatureInfo>)featureInfo
                connectivityState:(HUBConnectivityState)connectivityState
                    previousError:(nullable NSError *)previousError NS_SWIFT_NAME(appendContent(pageIndex:viewModelBuilder:viewURI:featureInfo:connectivityState:previousError:));

@end

NS_ASSUME_NONNULL_END
