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
 *  Extended Hub content operation protocol that adds the ability to add initial content to a view
 *
 *  Use this protocol whenever your content operation is able to add pre-loaded content to a view,
 *  that is rendered before the main content loading chain is started.
 *
 *  See `HUBContentOperation` for more information.
 */
@protocol HUBContentOperationWithInitialContent <HUBContentOperation>

/**
 *  Add any initial content for a view with a certain view URI, using a view model builder
 *
 *  @param viewURI The URI of the view that initial content should be added for
 *  @param viewModelBuilder The builder that can be used to add initial content
 *
 *  Initial content is always loaded synchronously, and is displayed for the user before the "real" view model of
 *  a view is loaded. It can be used to display a "skeleton" version of the final User Interface, or to add placeholder
 *  content. The key for this method is speed - it shouldn't be used to perform expensive operations or to load any
 *  final content.
 *
 *  In case no relevant content can be added by the content operation, it can just implement this method as a no-op.
 */
- (void)addInitialContentForViewURI:(NSURL *)viewURI
                 toViewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder NS_SWIFT_NAME(addInitialContent(viewURI:viewModelBuilder:));

@end

NS_ASSUME_NONNULL_END
