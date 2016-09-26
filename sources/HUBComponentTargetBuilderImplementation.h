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

#import "HUBComponentTargetBuilder.h"
#import "HUBHeaderMacros.h"

@protocol HUBJSONSchema;
@protocol HUBIconImageResolver;
@protocol HUBComponentTarget;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentTargetBuilder` API
@interface HUBComponentTargetBuilderImplementation : NSObject <HUBComponentTargetBuilder, NSCopying>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentDefaults The default component values for this instance of the Hub Framework
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 *  @param actionIdentifiers The initial action identifiers that the builder should contain
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                 actionIdentifiers:(nullable NSOrderedSet<HUBIdentifier *> *)actionIdentifiers HUB_DESIGNATED_INITIALIZER;

/// Build a component target instance from the data contained in this builder
- (id<HUBComponentTarget>)build;

@end

NS_ASSUME_NONNULL_END
