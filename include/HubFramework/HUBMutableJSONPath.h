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

@protocol HUBJSONPath;
@protocol HUBJSONBoolPath;
@protocol HUBJSONIntegerPath;
@protocol HUBJSONStringPath;
@protocol HUBJSONURLPath;
@protocol HUBJSONDictionaryPath;

NS_ASSUME_NONNULL_BEGIN

/// Block type used when running a custom block as a JSON path operation
typedef NSObject * _Nullable(^HUBMutableJSONPathBlock)(NSObject *input);

/**
 *  Protocol defining the API of a mutable JSON path, that is used to describe operations to perform to retrieve
 *  a certain piece of data from a JSON structure.
 *
 *  You use this API to customize how the Hub Framework should parse a downloaded JSON structure for a feature,
 *  by either extending an existing `HUBJSONPath` or creating a new one through `HUBJSONSchema`.
 *
 *  A path consists of a sequence of operations that each perform a JSON parsing task, such as going to a key in
 *  a dictionary, or iterating over an array. You append operations to a path by calling any of the methods listed
 *  under "Operations", and finally convert it into an immutable, destination path by calling any of the methods
 *  listed under "Destinations".
 *
 *  For example; if you wish to express the string "Sunday" from this JSON dictionary:
 *
 *  @code
 *  {
 *      "date": {
 *          "weekday": "Sunday"
 *      }
 *  }
 *  @endcode
 *
 *  You would construct a path accordingly:
 *
 *  @code
 *  [[[path goTo:@"date"] goTo:@"weekday"] stringPath];
 *  @endcode
 */
@protocol HUBMutableJSONPath <NSObject>

#pragma mark - Operations

/**
 *  Append an operation for going to a certain key in a JSON dictionary
 *
 *  @param key The key to go to
 *
 *  Use this API to traverse a JSON structure to reach the piece of data you're interested in. This operation
 *  can only be performed on dictionaries, and will fail in case it's applied on any other type.
 *
 *  @return A new mutable JSON path with the go to-operation appended. The path that you call this method on will
 *  not be modified.
 */
- (id<HUBMutableJSONPath>)goTo:(NSString *)key;

/**
 *  Append an operation for iterating through each element of a JSON array
 *
 *  Use this API to split a path into multiple sub-paths, one for each element of the target array. Any subsequent
 *  operations will be applied on all sub-paths. This operation can only be performed on arrays, and will fail in case
 *  it's applied on any other type.
 *
 *  @return A new mutable JSON path with the for each-operation appended. The path that you call this method on will
 *  not be modified.
 */
- (id<HUBMutableJSONPath>)forEach;

/**
 *  Append an operation using a custom block
 *
 *  Use this API to perform any custom JSON parsing logic on the current value of this path. When using this API you
 *  are responsible for your own type checking within the block, although the Hub Framework will always perform a
 *  final type-check at the end of the path.
 *
 *  @return A new mutable JSON path with the custom operation appended. The path that you call this method on will
 *  not be modified.
 */
- (id<HUBMutableJSONPath>)runBlock:(HUBMutableJSONPathBlock)block;

/**
 *  Combine this path with another one, forming a new path that combines the result of the two paths into an array
 *
 *  @param path The path to combine with the current path
 *
 *  This API can be used to provide backwards compatibility in an easy way when introducing new keys (or renaming
 *  existing ones) in a JSON schema. For paths which only are expected to produce a single value, the first value
 *  in the combination will be used, meaning that migration to new keys can be done without having to time client
 *  & backend releases, or introducing added complexity.
 *
 *  For example; say you want to rename the key "identifier" to "id" in this JSON:
 *
 *  @code
 *  {
 *      "identifier": "Sunday"
 *  }
 *  @endcode
 *
 *  You could then construct a combined path that picks either of the values for the "id" (preferred, since it's
 *  the new one) or "identifier" keys. Like this:
 *
 *  @code
 *  idPath = [[[schema createNewPath] goTo:@"id"] stringPath];
 *  identifierPath = [[[schema createNewPath] goTo:@"identifier"] stringPath];
 *  combinedPath = [idPath combineWithPath:identifierPath];
 *  @endcode
 */
- (id<HUBMutableJSONPath>)combineWithPath:(id<HUBMutableJSONPath>)path;

#pragma mark - Destinations

/**
 *  Turn this path into an immutable path that expects the destination value to be a `BOOL`
 */
- (id<HUBJSONBoolPath>)boolPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSInteger`
 */
- (id<HUBJSONIntegerPath>)integerPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSString`
 */
- (id<HUBJSONStringPath>)stringPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSString` that can be parsed
 *  into an `NSURL`.
 */
- (id<HUBJSONURLPath>)URLPath;

/**
 *  Turn this path into an immutable path that expects the destination value to be an `NSDictionary`
 */
- (id<HUBJSONDictionaryPath>)dictionaryPath;

#pragma mark - Copying

/// Copy this path, returning an immutable copy of it
- (id<HUBJSONPath>)copy;

@end

NS_ASSUME_NONNULL_END
