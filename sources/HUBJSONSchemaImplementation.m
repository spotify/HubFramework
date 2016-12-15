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

#import "HUBJSONSchemaImplementation.h"

#import "HUBViewModelJSONSchemaImplementation.h"
#import "HUBComponentModelJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchemaImplementation.h"
#import "HUBComponentTargetJSONSchemaImplementation.h"
#import "HUBMutableJSONPathImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONSchemaImplementation ()

@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;

@end

@implementation HUBJSONSchemaImplementation

@synthesize viewModelSchema = _viewModelSchema;
@synthesize componentModelSchema = _componentModelSchema;
@synthesize componentImageDataSchema = _componentImageDataSchema;
@synthesize componentTargetSchema = _componentTargetSchema;

#pragma mark - Initializers

- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults
                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    return [self initWithViewModelSchema:[HUBViewModelJSONSchemaImplementation new]
                    componentModelSchema:[HUBComponentModelJSONSchemaImplementation new]
                componentImageDataSchema:[HUBComponentImageDataJSONSchemaImplementation new]
                   componentTargetSchema:[HUBComponentTargetJSONSchemaImplementation new]
                       componentDefaults:componentDefaults
                       iconImageResolver:iconImageResolver];
}

- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
                  componentTargetSchema:(id<HUBComponentTargetJSONSchema>)componentTargetSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    NSParameterAssert(viewModelSchema != nil);
    NSParameterAssert(componentModelSchema != nil);
    NSParameterAssert(componentImageDataSchema != nil);
    NSParameterAssert(componentTargetSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    self = [super init];
    
    if (self) {
        _viewModelSchema = viewModelSchema;
        _componentModelSchema = componentModelSchema;
        _componentImageDataSchema = componentImageDataSchema;
        _componentTargetSchema = componentTargetSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
    }
    
    return self;
}

#pragma mark - HUBJSONSchema

- (id<HUBMutableJSONPath>)createNewPath
{
    return [[HUBMutableJSONPathImplementation alloc] initWithParsingOperations:@[]];
}

- (id)copy
{
    return [[HUBJSONSchemaImplementation alloc] initWithViewModelSchema:[self.viewModelSchema copy]
                                                   componentModelSchema:[self.componentModelSchema copy]
                                               componentImageDataSchema:[self.componentImageDataSchema copy]
                                                  componentTargetSchema:[self.componentTargetSchema copy]
                                                      componentDefaults:self.componentDefaults
                                                      iconImageResolver:self.iconImageResolver];
}

- (id<HUBViewModel>)viewModelFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:self
                                                                                                    componentDefaults:self.componentDefaults
                                                                                                    iconImageResolver:self.iconImageResolver];
    
    [builder addJSONDictionary:dictionary];
    return [builder build];
}

@end

NS_ASSUME_NONNULL_END
