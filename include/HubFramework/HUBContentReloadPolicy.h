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

/**
 *  Protocol used to define objects that represent a policy for when the content for a view should be reloaded
 *
 *  To define a reload policy, conform to this protocol in a custom object and pass it when registering your
 *  feature with `HUBFeatureRegistry`. A reload policy can be used to implement custom rules around when to
 *  reload a given view.
 *
 *  Each application using the Hub Framework also has a default content reload policy used for features that
 *  do not declare their own. This reload policy is passed when setting up `HUBManager`.
 */
@protocol HUBContentReloadPolicy <NSObject>

/**
 *  Return whether the content for a view should be reloaded
 *
 *  @param viewURI The URI of the view
 *  @param currentViewModel The current view model of the view
 *
 *  The Hub Framework will call this method every time a view that has already loaded a view model is about
 *  to appear on the screen. The passed `currentViewModel` can be used to inspect the current content of the
 *  view, as well as the view model's `buildDate` to determine whether a view should be reloaded or not.
 */
- (BOOL)shouldReloadContentForViewURI:(NSURL *)viewURI currentViewModel:(id<HUBViewModel>)currentViewModel;

@end

NS_ASSUME_NONNULL_END
