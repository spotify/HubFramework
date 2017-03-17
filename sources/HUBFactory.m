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

#import "HUBFactory.h"

#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandler.h"
#import "HUBDefaultComponentFallbackHandler.h"
#import "HUBJSONSchemaImplementation.h"


@implementation HUBFactory


- (id<HUBComponentFallbackHandler>)createComponentFallbackHandlerWithBlock:(id<HUBComponent>(^)(HUBComponentCategory))componentFallbackBlock
{
    return [[HUBDefaultComponentFallbackHandler alloc] initWithFallbackBlock:componentFallbackBlock];
}

- (id<HUBJSONSchema>)createDefaultJSONSchemaWithComponentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                                                    iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    HUBComponentDefaults * const componentDefaults =
    [[HUBComponentDefaults alloc] initWithComponentNamespace:componentFallbackHandler.defaultComponentNamespace
                                               componentName:componentFallbackHandler.defaultComponentName
                                           componentCategory:componentFallbackHandler.defaultComponentCategory];

    return [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                        iconImageResolver:iconImageResolver];
}

@end
