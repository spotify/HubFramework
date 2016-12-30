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

#import "HUBJSONPath.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a JSON schema for `HUBComponentTarget`
 *
 *  You don't conform to this protocol yourself, instead an object matching the default Hub Framework schema will
 *  come attached to a `HUBJSONSchema`. You are free to customize a schema in whatever way you want, but you must
 *  do so before registering it with the `HUBJSONSchemaRegistry`.
 *
 *  The Hub Framework uses a path-based approach to JSON parsing, that enables you to describe how to retrieve data
 *  from a JSON structure using paths - sequences of operations that each perform a JSON parsing task, such as going
 *  to a key in a dictionary, or iterating over an array. For more information about how to construct paths, see the
 *  documentation for `HUBJSONPath` and `HUBMutableJSONPath`.
 *
 *  All paths in this schema are relative to a dictionary containing target data for a component.
 */
@protocol HUBComponentTargetJSONSchema

/// The path to follow to extract a target URI string. Maps to `URI`.
@property (nonatomic, strong) id<HUBJSONURLPath> URIPath;

/**
 *  The path to follow to extract an initial view model dictionary for the target. Maps to `initialViewModel`.
 *
 *  The dictionary extracted by following this path will then be parsed using `HUBViewModelJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> initialViewModelDictionaryPath;

/// The path to follow to extract an array of action identifiers for the target. Maps to `actionIdentifiers`.
@property (nonatomic, strong) id<HUBJSONStringPath> actionIdentifiersPath;

/// The path to follow to extract any custom data for the target. Maps to `customData`.
@property (nonatomic, strong) id<HUBJSONDictionaryPath> customDataPath;

/// Create a copy of this schema, with the same paths
- (id<HUBComponentTargetJSONSchema>)copy;

@end

NS_ASSUME_NONNULL_END

