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

@protocol HUBJSONSchema;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API for adding JSON data to a Hub Framework model builder
 *
 *  Builders that support JSON data will conform to this protocol. Most builders only support Dictionary-based
 *  JSON, except for `HUBViewModelBuilder` that supports Array-based JSON for defining an array of body
 *  component models.
 */
@protocol HUBJSONCompatibleBuilder <NSObject>

/**
 *  Add binary JSON data to the builder
 *
 *  @param JSONData The JSON data to add
 *
 *  The builder will use its feature's `HUBJSONSchema` to parse the data that was added, and return any error that
 *  occured while doing so, or nil if the operation was completed successfully.
 */
- (nullable NSError *)addJSONData:(NSData *)JSONData;

/**
 *  Add a JSON dictionary to this builder
 *
 *  @param dictionary The JSON dictionary to extract content from
 *
 *  The content that was extracted from the supplied dictionary will replace any previously defined content.
 */
- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary;

@end

NS_ASSUME_NONNULL_END

