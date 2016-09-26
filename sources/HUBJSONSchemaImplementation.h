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

#import "HUBJSONSchema.h"
#import "HUBHeaderMacros.h"

@protocol HUBIconImageResolver;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchema` API
@interface HUBJSONSchemaImplementation : NSObject <HUBJSONSchema>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param componentDefaults The default component values to use when parsing JSON
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults
                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver;

/**
 *  Initialize an instance of this class with all required sub-schemas
 *
 *  @param viewModelSchema The schema to use for view models
 *  @param componentModelSchema The schema to use for component models
 *  @param componentImageDataSchema The schema to use for component image data
 *  @param componentTargetSchema The schema to use for component targets
 *  @param componentDefaults The default component values to use when parsing JSON
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 *
 *  In order to create default implementations of all sub-schemas, use the convenience initializer.
 */
- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
                  componentTargetSchema:(id<HUBComponentTargetJSONSchema>)componentTargetSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
