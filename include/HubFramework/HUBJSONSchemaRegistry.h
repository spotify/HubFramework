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
 *  Protocol defining the public API of a Hub JSON schema registry
 *
 *  You don't conform to this protocol yourself, instead the application's `HUBManager` has an object conforming
 *  to this protocol attached to it, that enables you to create and register custom JSON schemas for use in the
 *  Hub Framework.
 *
 *  To customize a schema, create one using `-createNewSchema`, then set up the returned schema to match the JSON
 *  format that you are expecting, and finally register it with the registry.
 *
 *  For more information on how Hub Framework JSON schemas work; see `HUBJSONSchema`.
 */
@protocol HUBJSONSchemaRegistry <NSObject>

/**
 *  Create a new JSON schema that can be customized for a custom JSON format
 *
 *  The returned schema comes setup according to the default Hub Framework JSON schema, so you are free to customize
 *  only the parts of it that you need to.
 */
- (id<HUBJSONSchema>)createNewSchema;

/**
 *  Create a new JSON schema that is a copy of any previously registed schema
 *
 *  @param identifier The identifier of the schema to copy
 *
 *  @return A copied schema, or nil if a schema wasn't found for the given identifier
 */
- (nullable id<HUBJSONSchema>)copySchemaWithIdentifier:(NSString *)identifier;

/**
 *  Register a custom JSON schema for use with the Hub Framework
 *
 *  @param schema The schema to register
 *  @param identifier The identifier to register the schema for
 *
 *  The identifier that this schema gets registered for must be unique. If another schema has already been registered
 *  for the given identifier, an assert will be triggered. To get the Hub Framework to use your custom schema to parse
 *  any downloaded JSON, supply its identifier when registering your feature with `HUBFeatureRegistry`.
 */
- (void)registerCustomSchema:(id<HUBJSONSchema>)schema forIdentifier:(NSString *)identifier;

/**
 *  Unregister a custom JSON schema from the Hub Framework
 *
 *  @param identifier The identifier to unregister a schema for
 *
 *  Calling this will remove the custom JSON schema from the framework, opening up the identifier for use by other schemas.
 */
- (void)unregisterCustomSchemaWithIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
