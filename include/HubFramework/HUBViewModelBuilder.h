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

#import "HUBJSONCompatibleBuilder.h"

@protocol HUBComponentModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a builder that builds view model objects
 *
 *  This builder acts like a mutable model counterpart for `HUBViewModel`, with the key difference that they
 *  are not related by inheritance.
 *
 *  For more information regarding the properties that this builder enables you to set, see the documentation
 *  for `HUBViewModel`.
 */
@protocol HUBViewModelBuilder <HUBJSONCompatibleBuilder>

#pragma mark - The status of the builder

/**
 *  Whether this builder is currently empty, and does not contain any content
 *
 *  As soon as any header or body component model has been added to this builder, it is no longer considered empty
 */
@property (nonatomic, readonly) BOOL isEmpty;

#pragma mark - Identifier

/**
 *  The identifier that the view should have
 *
 *  The value of this property doesn't have any specific format or constraints and doesn't explicitly need to be
 *  unique - but for logging, UI instrumentation and identification purposes, it's definitely recommended.
 *
 *  The default value of this property is either a view identifier derived from remote content JSON data or nil.
 */
@property (nonatomic, copy, nullable) NSString *viewIdentifier;

#pragma mark - Navigation bar & header

/**
 *  The title that the view should have in the navigation bar
 *
 *  The value of this property will be assigned to the view controller's title property
 */
@property (nonatomic, copy, nullable) NSString *navigationBarTitle;

/**
 *  The builder to use to build a model for the view's header component
 *
 *  If you plan to add a header to your view, you use this builder to setup the component that will make up the header.
 *  This builder gets lazily created the first time you access this property, and will cause a component-based header to
 *  be added to the view. If this property is never accessed, a `UINavigationBar`-based header will be used instead.
 *
 *  To remove this view model builder's header component builder, use `-removeHeaderComponentModelBuilder`.
 *  To check whether a header component model builder currently exists, use `headerComponentModelBuilderExists`.
 *
 *  In case no identifier is explicity defined for the returned builder, it will use "header" as the default.
 */
@property (nonatomic, strong, readonly) id<HUBComponentModelBuilder> headerComponentModelBuilder;

/**
 *  Whether a builder for a model for the view's header component currently exists
 *
 *  Since accessing `headerCompoentModelBuilder` lazily creates a builder, you can use this property to check for the
 *  existance of a builder.
 */
@property (nonatomic, readonly) BOOL headerComponentModelBuilderExists;

#pragma mark - Metadata

/**
 *  Any HTTP URL from which data can be downloaded to extend the view model
 *
 *  You can use this property to implement pagination for your view's content. When the user has scrolled to the bottom
 *  of a view, and that view model's extension URL != nil, the Hub Framework will automatically ask its content operations
 *  to extend the view model with data from this URL.
 */
@property (nonatomic, copy, nullable) NSURL *extensionURL;

/**
 *  Any custom data that should be associated with the view model
 *
 *  You can use this property to pass any information along in the content loading process, into the view model itself.
 *  That data may later be used to make decisions in a view's delegate. It's useful for simple customization, but for
 *  extended use consider making a contribution to the main `HUBViewModel` API instead, if it's some piece of data that
 *  is considered useful for other API users as well.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSObject *> *customData;

#pragma mark - Checking if component model builders exist

/**
 *  Return whether this builder contains a builder for a body component model with a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForBodyComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Return whether this builder contains a builder for an overlay component model with a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForOverlayComponentModelWithIdentifier:(NSString *)identifier;

#pragma mark - Retrieving component model builders

/**
 *  Return all current body component model builders
 *
 *  @return All the existing body component model builders, in the order that they were created. Note that
 *  any `preferredIndex` set by the component model builders hasn't been resolved at this point, so those
 *  are not taken into account.
 */
- (NSArray<id<HUBComponentModelBuilder>> *)allBodyComponentModelBuilders;

/**
 *  Get or create a builder for a body component model with a certain identifier
 *
 *  @param identifier The identifier that the component model should have
 *
 *  @return If a body component model builder already exists for the supplied identifier, then it's returned. Otherwise a
 *  new builder is created, which can be used to build a body component model. Since this method lazily creates a builder
 *  in case one doesn't already exist, use the `-builderExistsForBodyComponentModelWithIdentifier:` API instead if you
 *  simply wish to check for the existance of a builder. See `HUBComponentModelBuilder` for more information.
 */
- (id<HUBComponentModelBuilder>)builderForBodyComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Get or create a builder for an overlay component model with a certain identifier
 *
 *  @param identifier The identifier that the component model should have
 *
 *  @return If an overlay component model builder already exists for the supplied identifier, then it's returned. Otherwise a
 *  new builder is created, which can be used to build an overlay component model. Since this method lazily creates a builder
 *  in case one doesn't already exist, use the `-builderExistsForOverlayComponentModelWithIdentifier:` API instead if you
 *  simply wish to check for the existance of a builder.
 *
 *  Use overlay component model builders to setup any components that will be rendered as overlays for the view, on top of the
 *  rest of the view's content. This can be used to display loading indicators, popups, or other overlay content. Overlays are
 *  always rendered at the center of their container view, stacked on top of each other on the z axis. The components indexes
 *  (can be controlled by setting `preferredIndex` on their component model builders) determines the rendering order.
 *
 *  See `HUBComponentModelBuilder` for more information.
 */
- (id<HUBComponentModelBuilder>)builderForOverlayComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Enumerate all component model builders contained within this builder
 *
 *  @param block A block used for enumeration, will be passed each component model builder found as an argument, and is expected
 *         to return a BOOL indicating whether the enumeration should continue or not. As soon as an enumeration block returns
 *         `NO`, the enumeration will stop.
 *
 *  The enumeration will start with any header component model builder, then move onto body component model builders and finally
 *  overlay component model builders. You can use this API either to inspect all the component content of a view model builder, or
 *  perform a sequence of operations on them easily.
 */
- (void)enumerateAllComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block;

#pragma mark - Removing component model builders

/**
 *  Remove any previously created header component model builder
 *
 *  Removing the header component model builder will cause the view to use a `UINavigationBar`-based header instead.
 */
- (void)removeHeaderComponentModelBuilder;

/**
 *  Remove a builder for a body component with a certain identifier
 *
 *  @param identifier The identifier of the component model builder to remove
 */
- (void)removeBuilderForBodyComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Remove a builder for an overlay component with a certain identifier
 *
 *  @param identifier The identifier of the component model builder to remove
 */
- (void)removeBuilderForOverlayComponentModelWithIdentifier:(NSString *)identifier;

/**
 *  Remove all component model builders that this builder contains
 *
 *  All body component model builders, as well as any header component model builder, will be removed.
 */
- (void)removeAllComponentModelBuilders;

@end

NS_ASSUME_NONNULL_END
