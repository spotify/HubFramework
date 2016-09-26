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
#import "HUBComponentModel.h"
#import "HUBHeaderMacros.h"

@class HUBIdentifier;
@protocol HUBIcon;
@protocol HUBComponentTarget;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentModel` API
@interface HUBComponentModelImplementation : HUBAutoEquatable <HUBComponentModel>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier The identifier of the model
 *  @param type The type of component that this model is for
 *  @param index The index of the model, either within its parent or within the root list
 *  @param groupIdentifier Any logical group that the component model should belong to
 *  @param componentIdentifier The identifier of the component that the model should be rendered using
 *  @param componentCategory The category of the component that the model should be rendered using
 *  @param title Any title that the component should render
 *  @param subtitle Any subtitle that the component should render
 *  @param accessoryTitle Any accessory title that the component should render
 *  @param descriptionText Any description text that the component should render
 *  @param mainImageData Any image data for the component's "main" image
 *  @param backgroundImageData Any image data for the component's background image
 *  @param customImageData Any image data objects describing layout properties for custom images for the component
 *  @param icon Any icon that the component should render
 *  @param target Any target of user interactions with the component
 *  @param metadata Any metadata that should be associated with the component
 *  @param loggingData Any data that should be logged alongside interactions or impressions for the component
 *  @param customData Any custom data that the component should use
 *  @param parent Any model that is the parent of this one
 *
 *  For more information about these parameters and their corresponding properties, see their
 *  documentation in `HUBComponentModel`.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                              type:(HUBComponentType)type
                             index:(NSUInteger)index
                   groupIdentifier:(nullable NSString *)groupIdentifier
               componentIdentifier:(HUBIdentifier *)componentIdentifier
                 componentCategory:(HUBComponentCategory)componentCategory
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                    accessoryTitle:(nullable NSString *)accessoryTitle
                   descriptionText:(nullable NSString *)descriptionText
                     mainImageData:(nullable id<HUBComponentImageData>)mainImageData
               backgroundImageData:(nullable id<HUBComponentImageData>)backgroundImageData
                   customImageData:(NSDictionary<NSString *, id<HUBComponentImageData>> *)customImageData
                              icon:(nullable id<HUBIcon>)icon
                            target:(nullable id<HUBComponentTarget>)target
                          metadata:(nullable NSDictionary<NSString *, NSObject *> *)metadata
                       loggingData:(nullable NSDictionary<NSString *, NSObject *> *)loggingData
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
                            parent:(nullable id<HUBComponentModel>)parent HUB_DESIGNATED_INITIALIZER;

/// The component models that are children of this one
@property (nonatomic, strong, nullable) NSArray<id<HUBComponentModel>> *children;

@end

NS_ASSUME_NONNULL_END
