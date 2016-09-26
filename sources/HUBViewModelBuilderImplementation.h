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

#import "HUBViewModelBuilder.h"
#import "HUBHeaderMacros.h"

@protocol HUBJSONSchema;
@protocol HUBIconImageResolver;
@protocol HUBViewModel;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelBuilder` API
@interface HUBViewModelBuilderImplementation : NSObject <HUBViewModelBuilder, NSCopying>

/**
 *  Initialize an instance of this class with a feature identifier
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentDefaults The default values to use for component model builders
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

/**
 *  Build a view model instance from the data contained in this builder
 */
- (id<HUBViewModel>)build;

@end

NS_ASSUME_NONNULL_END
