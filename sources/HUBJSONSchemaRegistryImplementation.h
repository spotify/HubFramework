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

#import "HUBJSONSchemaRegistry.h"
#import "HUBHeaderMacros.h"

@protocol HUBIconImageResolver;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchemaRegistry` API
@interface HUBJSONSchemaRegistryImplementation : NSObject <HUBJSONSchemaRegistry>

/// The default JSON schema that is used when a feature has not declared a custom JSON schema identifier
@property (nonatomic, strong, readonly) id<HUBJSONSchema> defaultSchema;

/**
 *  Initialize an instance of this class with a set of component default values
 *
 *  @param componentDefaults The default component values to use when parsing JSON
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults
                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

/**
 *  Return a custom JSON schema that has been registered for a certain identifier
 *
 *  If a schema does not exist for the given identifier, `nil` is returned.
 */
- (nullable id<HUBJSONSchema>)customSchemaForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
