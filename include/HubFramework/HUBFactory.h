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

#import "HUBComponentCategories.h"

@protocol HUBComponent;
@protocol HUBComponentFallbackHandler;
@protocol HUBIconImageResolver;
@protocol HUBJSONSchema;

NS_ASSUME_NONNULL_BEGIN


/**
 *  Factory to create some commonly used default implementations from Hub Framework.
 */
@interface HUBFactory : NSObject


/**
 *  Creates a block based `HUBComponentFallbackHandler`.
 *
 *  This is a simple fallback handler that uses a factory block to create components.
 *
 *  @param block The factory block to create components.
 *
 *  @return A newly created `HUBComponentFallbackHandler`.
 */
- (id<HUBComponentFallbackHandler>)createComponentFallbackHandlerWithBlock:(id<HUBComponent>(^)(HUBComponentCategory))block;

/**
 *  Create a new instance of the default JSON schema with specified parameters.
 *
 *  @param defaultComponentNamespace The default component namespace.
 *  @param defaultComponentName The default component name.
 *  @param defaultComponentCategory The default component category.
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
*
 *  @return A newly created `HUBJSONSchema`.
 */
- (id<HUBJSONSchema>)createDefaultJSONSchemaWithDefaultComponentNamespace:(NSString *)defaultComponentNamespace
                                                     defaultComponentName:(NSString *)defaultComponentName
                                                 defaultComponentCategory:(HUBComponentCategory)defaultComponentCategory
                                                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver;

@end

NS_ASSUME_NONNULL_END
