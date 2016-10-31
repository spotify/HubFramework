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

@protocol HUBJSONStringPath;
@protocol HUBJSONDictionaryPath;
@protocol HUBJSONURLPath;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a JSON schema for `HUBViewModel`
 *
 *  You don't conform to this protocol yourself, instead an object conforming to it will come attached
 *  when you create a `HUBJSONSchema` (see its documentation for more info). The implementation of this
 *  protocol will come setup according to the default Hub Framework JSON schema, but you're free to change
 *  & extend it to fit any schema that you expect your JSON data to conform to.
 *
 *  A schema is defined as a collection of paths, that each describe the operations required to extract
 *  a certain piece of data from a JSON structure. For a more in-depth description on how paths work, see the
 *  documentation for `HUBJSONPath` and `HUBMutableJSONPath`. For more information about the properties that
 *  the data extracted using this schema will be used for, see `HUBViewModel`.
 *
 *  To change a path - either create a `mutableCopy` of it, change it, and re-assign it back to its property,
 *  or create a new path from scratch using `HUBJSONSchema`.
 *
 *  All paths in this schema are relative to a JSON dictionary defining view model data.
 */
@protocol HUBViewModelJSONSchema <NSObject>

/// The path to follow to extract a view model identifier. Maps to `identifier`.
@property (nonatomic, strong) id<HUBJSONStringPath> identifierPath;

/// The path to follow to extract a navigation bar title. Maps to `navigationBarTitle`.
@property (nonatomic, strong) id<HUBJSONStringPath> navigationBarTitlePath;

/**
 *  The path to follow to extract a dictionary for any component model for the view's header.
 *  Maps to `headerComponentModel`.
 *
 *  The dictionary extracted by following this path will then be parsed using `HUBComponentModelJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> headerComponentModelDictionaryPath;

/**
 *  The path to follow to extract an array of dictionaries for the component models for the view's body.
 *  Maps to `bodyComponentModels`.
 *
 *  The dictionaries extractd by following this path will then be parsed using `HUBComponentModelJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> bodyComponentModelDictionariesPath;

/**
 *  The path to follow to extract an array of dictionaries for the view's overlay component models.
 *  Maps to `overlayComponentModel`.
 *
 *  The dictionary extracted by following this path will then be parsed using `HUBComponentModelJSONSchema`.
 */
@property (nonatomic, strong) id<HUBJSONDictionaryPath> overlayComponentModelDictionariesPath;

/// The path to follow to extract custom data for a view model. Maps to `customData`.
@property (nonatomic, strong) id<HUBJSONDictionaryPath> customDataPath;

/// Create a copy of this schema, with the same paths
- (id<HUBViewModelJSONSchema>)copy;

@end

NS_ASSUME_NONNULL_END
