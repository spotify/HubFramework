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

#import "HUBComponentTargetBuilderImplementation.h"

#import "HUBViewModelBuilderImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentTargetJSONSchema.h"
#import "HUBComponentTargetImplementation.h"
#import "HUBIdentifier.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentTargetBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *initialViewModelBuilderImplementation;

@end

@implementation HUBComponentTargetBuilderImplementation

@synthesize URI = _URI;
@synthesize actionIdentifiers = _actionIdentifiers;
@synthesize customData = _customData;

#pragma mark - Initializer

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                 actionIdentifiers:(nullable NSOrderedSet<HUBIdentifier *> *)actionIdentifiers
{
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
        _actionIdentifiers = (NSMutableOrderedSet *)([actionIdentifiers mutableCopy] ?: [NSMutableOrderedSet new]);
    }
    
    return self;
}

#pragma mark - API

- (id<HUBComponentTarget>)build
{
    id<HUBViewModel> const initialViewModel = [self.initialViewModelBuilderImplementation build];
    NSArray<HUBIdentifier *> * const actionIdentifiers = self.actionIdentifiers.count > 0 ? self.actionIdentifiers.array : nil;
    
    return [[HUBComponentTargetImplementation alloc] initWithURI:self.URI
                                                initialViewModel:initialViewModel
                                               actionIdentifiers:actionIdentifiers
                                                      customData:self.customData];
}

#pragma mark - HUBComponentTargetBuilder

- (id<HUBViewModelBuilder>)initialViewModelBuilder
{
    return [self getOrCreateInitialViewModelBuilder];
}

- (void)addActionWithNamespace:(NSString *)actionNamespace name:(NSString *)actionName
{
    HUBIdentifier * const identifier = [[HUBIdentifier alloc] initWithNamespace:actionNamespace name:actionName];
    [self.actionIdentifiers addObject:identifier];
}

#pragma mark - HUBJSONCompatibleBuilder

- (nullable NSError *)addJSONData:(NSData *)JSONData
{
    return nil;//HUBAddJSONDataToBuilder(JSONData, self);
}

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBComponentTargetJSONSchema> const schema = self.JSONSchema.componentTargetSchema;
    
    NSURL * const URI = [schema.URIPath URLFromJSONDictionary:dictionary];
    
    if (URI != nil) {
        self.URI = URI;
    }
    
    NSDictionary * const initialViewModelDictionary = [schema.initialViewModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (initialViewModelDictionary != nil) {
        [[self getOrCreateInitialViewModelBuilder] addDataFromJSONDictionary:initialViewModelDictionary];
    }
    
    NSArray<NSString *> * const actionIdentifierStrings = [schema.actionIdentifiersPath valuesFromJSONDictionary:dictionary];
    
    for (NSString * const actionIdentifierString in actionIdentifierStrings) {
        HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithString:actionIdentifierString];
        
        if (actionIdentifier != nil) {
            [self.actionIdentifiers addObject:actionIdentifier];
        }
    }
    
    NSDictionary * const customData = [schema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (customData != nil) {
        self.customData = HUBMergeDictionaries(self.customData, customData);
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBComponentTargetBuilderImplementation * const copy = [[HUBComponentTargetBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                             componentDefaults:self.componentDefaults
                                                                                                             iconImageResolver:self.iconImageResolver
                                                                                                             actionIdentifiers:self.actionIdentifiers];
    
    copy.URI = self.URI;
    copy.initialViewModelBuilderImplementation = [self.initialViewModelBuilderImplementation copy];
    copy.customData = self.customData;
    
    return copy;
}

#pragma mark - Private utilities

- (HUBViewModelBuilderImplementation *)getOrCreateInitialViewModelBuilder
{
    if (self.initialViewModelBuilderImplementation != nil) {
        return (HUBViewModelBuilderImplementation *)self.initialViewModelBuilderImplementation;
    }
    
    HUBViewModelBuilderImplementation * const initialViewModelBuilderImplementation = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                                                  componentDefaults:self.componentDefaults
                                                                                                                                  iconImageResolver:self.iconImageResolver];
    
    self.initialViewModelBuilderImplementation = initialViewModelBuilderImplementation;
    return initialViewModelBuilderImplementation;
}

@end

NS_ASSUME_NONNULL_END
