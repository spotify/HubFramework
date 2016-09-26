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

#import "HUBJSONSchemaRegistryImplementation.h"

#import "HUBJSONSchemaImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONSchemaRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBJSONSchema>> *customSchemasByIdentifier;

@end

@implementation HUBJSONSchemaRegistryImplementation

- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults
                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    NSParameterAssert(componentDefaults != nil);
    
    self = [super init];
    
    if (self) {
        _defaultSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
        _customSchemasByIdentifier = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (nullable id<HUBJSONSchema>)customSchemaForIdentifier:(NSString *)identifier
{
    return self.customSchemasByIdentifier[identifier];
}

#pragma mark - HUBJSONSchemaRegistry

- (id<HUBJSONSchema>)createNewSchema
{
    return [self.defaultSchema copy];
}

- (nullable id<HUBJSONSchema>)copySchemaWithIdentifier:(NSString *)identifier
{
    return [self.customSchemasByIdentifier[identifier] copy];
}

- (void)registerCustomSchema:(id<HUBJSONSchema>)schema forIdentifier:(NSString *)identifier
{
    NSAssert(self.customSchemasByIdentifier[identifier] == nil,
             @"Attempted to register a JSON schema for an identifier that is already registered: %@",
             identifier);
    
    [self.customSchemasByIdentifier setObject:schema forKey:identifier];
}

@end

NS_ASSUME_NONNULL_END
