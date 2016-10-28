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

#import <UIKit/UIKit.h>

#import "HUBJSONCompatibleBuilder.h"
#import "HUBComponentCategories.h"

@protocol HUBComponentImageDataBuilder;
@protocol HUBComponentTargetBuilder;
@protocol HUBComponentModelBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public delegate API for a builder that builds component model objects
 *
 *  This delegate protocol can be implemented to react to changes happening to a 
 *  component model builder.
 */
@protocol HUBComponentModelBuilderDelegate <NSObject>

/**
 *  Notifies the delegate that the group identifier for a component model builder did change
 *
 *  @param componentModelBuilder The component model builder whose group identifier did change
 *  @param groupIdentifier The new group identifier
 *  @param oldGroupIdentifier The old group identifier
 */
- (void)componentModelBuilder:(id<HUBComponentModelBuilder>)componentModelBuilder groupIdentifierDidChange:(nullable NSString *)groupIdentifier oldGroupIdentifier:(nullable NSString *)oldGroupIdentifier;

@end

/**
 *  Protocol defining the public API for a builder that builds component model objects
 *
 *  This builder acts like a mutable model counterpart for `HUBComponentModel`, with the key
 *  difference that they are not related by inheritance.
 *
 *  All properties are briefly documented as part of this protocol, but for more extensive
 *  documentation and use case examples, see the full documentation in the `HUBComponentModel`
 *  protocol definition.
 */
@protocol HUBComponentModelBuilder <HUBJSONCompatibleBuilder>

#pragma mark - Delegate

@property (nonatomic, weak) id<HUBComponentModelBuilderDelegate> delegate;

#pragma mark - Identifiers

/// The identifier of the model that this builder is for
@property (nonatomic, copy, readonly) NSString *modelIdentifier;

/// The index that the component would prefer to be placed at. Can be used to move components locally.
@property (nonatomic, copy, nullable) NSNumber *preferredIndex;

/// The identifier of any logical group to put the component model in within its parent.
@property (nonatomic, copy, nullable) NSString *groupIdentifier;

#pragma mark - Component

/**
 *  The namespace of the component that the model should be rendered using
 *
 *  The default value of this property is the `defaultComponentNamespace` declared by the application's implementation
 *  of `HUBComponentFallbackHandler`. If overriden, it should match the namespace of a registered `HUBComponentFactory`,
 *  which will be asked to create a component for the model's `componentName`.
 *
 *  In case no `HUBComponentFactory` could be resolved for the namespace, the Hub Framework will use its fallback handler
 *  to create a fallback component using the model's `componentCategory`.
 */
@property (nonatomic, copy) NSString *componentNamespace;

/**
 *  The name of the component that the model should be rendered using
 *
 *  The default value of this property is the `defaultComponentName` declared by the application's implementation
 *  of `HUBComponentFallbackHandler`. It will be sent to the `HUBComponentFactory` resolved for `componentNamespace`,
 *  which will be asked to create a component for the model.
 */
@property (nonatomic, copy) NSString *componentName;

/**
 *  The category of the component that the model should be rendered using
 *
 *  The default value of this property is the `defaultComponentCategory` declared by the application's implementation
 *  of `HUBComponentFallbackHandler`. It is sent to the fallback handler in case no component could be created for the
 *  model's `componentNamespace`/`componentName` combo - so that a fallback component may be created with similar
 *  visuals as the originally intended component.
 */
@property (nonatomic, copy) HUBComponentCategory componentCategory;

#pragma mark - Text

/// Any title that the component should render
@property (nonatomic, copy, nullable) NSString *title;

/// Any subtitle that the component should render
@property (nonatomic, copy, nullable) NSString *subtitle;

/// Any accessory title that the component should render
@property (nonatomic, copy, nullable) NSString *accessoryTitle;

/// Any longer describing text that the component should render
@property (nonatomic, copy, nullable) NSString *descriptionText;

#pragma mark - Images

/// A builder that can be used to construct data that describes how to render the component's "main" image
@property (nonatomic, strong, readonly) id<HUBComponentImageDataBuilder> mainImageDataBuilder;

/// Any URL for the component's "main" image. This is an alias for `mainImageDataBuilder.URL`.
@property (nonatomic, copy, nullable) NSURL *mainImageURL;

/// Any local component "main" image. This is an alias for `mainImageDataBuilder.localImage`.
@property (nonatomic, strong, nullable) UIImage *mainImage;

/// A builder that can be used to construct data that describes how to render the component's background image
@property (nonatomic, strong, readonly) id<HUBComponentImageDataBuilder> backgroundImageDataBuilder;

/// Any URL for the component's background image. This is an alias for `backgroundImageDataBuilder.URL`.
@property (nonatomic, copy, nullable) NSURL *backgroundImageURL;

/// Any local component background image. This is an alias for `backgroundImageDataBuilder.localImage`.
@property (nonatomic, strong, nullable) UIImage *backgroundImage;

/// Any identifier of any icon that should be used with the component
@property (nonatomic, copy, nullable) NSString *iconIdentifier;

#pragma mark - Target

/// A builder that can be used to construct target data for the component
@property (nonatomic, strong, readonly) id<HUBComponentTargetBuilder> targetBuilder;

#pragma mark - Metadata

/// Any application-specific model metadata that should be associated with the component
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *metadata;

/// Any data that should be logged alongside interactions or impressions for the component
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *loggingData;

/// Any custom data that the component should use
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *customData;

#pragma mark - Custom image data builders

/**
 *  Return whether this builder contains a builder for custom image data for a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForCustomImageDataWithIdentifier:(NSString *)identifier;

/**
 *  Get or create a builder for data for a custom image with a certain identifier
 *
 *  @param identifier The identifier of the image
 *
 *  @return If a builder already exists for the supplied identifier, then it's returned. Otherwise a new builder is
 *  created, which can be used to build an image data model. Since this method lazily creates a builder in case one
 *  doesn't already exist, use the `-builderExistsForImageDataWithIdentifier:` API instead if you simply wish to
 *  check for the existance of a builder. See `HUBComponentImageDataBuilder` for more information.
 */
- (id<HUBComponentImageDataBuilder>)builderForCustomImageDataWithIdentifier:(NSString *)identifier;

#pragma mark - Child component model builders

/**
 *  Return all current child component model builders
 *
 *  @return All the existing child component model builders, in the order that they were created. Note that
 *  any `preferredIndex` set by the component model builders hasn't been resolved at this point, so those
 *  are not taken into account.
 */
- (NSArray<id<HUBComponentModelBuilder>> *)allChildBuilders;

/**
 *  Return whether this builder contains a builder for a child component model builder with a certain identifier
 *
 *  @param identifier The identifier to look for
 */
- (BOOL)builderExistsForChildWithIdentifier:(NSString *)identifier;

/**
 *  Get or create a builder for a child component model with a certain identifier
 *
 *  @param identifier The identifier that the component model should have
 *
 *  @return If a builder already exists for the supplied identifier, then it's returned. Otherwise a new builder is
 *  created, which can be used to build a child component model. If a new builder is created, it will have the same
 *  `componentNamespace` and `componentName` as its parent. Since this method lazily creates a builder in case one
 *  doesn't already exist, use the `-builderExistsForChildComponentModelWithIdentifier:` API instead if you simply
 *  wish to check for the existance of a builder.
 */
- (id<HUBComponentModelBuilder>)builderForChildWithIdentifier:(NSString *)identifier NS_SWIFT_NAME(builderForChild(withIdentifier:));

/**
 *  Return child component model builders with a certain group identifier
 *
 *  @return All the existing child component model builders with the same group identifier, in the order that they were created.
 */
- (nullable NSArray<id<HUBComponentModelBuilder>> *)buildersForChildrenInGroupWithIdentifier:(NSString *)groupIdentifier;

/**
 *  Remove a builder for a child component model with a certain identifier
 *
 *  @param identifier The identifier of the child component model builder to remove
 */
- (void)removeBuilderForChildWithIdentifier:(NSString *)identifier NS_SWIFT_NAME(removeBuilderForChild(withIdentifier:));

/**
 *  Remove all builders for child component models contained within this builder
 */
- (void)removeAllChildBuilders;

@end

NS_ASSUME_NONNULL_END
