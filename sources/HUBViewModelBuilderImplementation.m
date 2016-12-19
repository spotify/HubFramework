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

#import "HUBViewModelBuilderImplementation.h"

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelJSONSchema.h"
#import "HUBComponentModelJSONSchema.h"
#import "HUBJSONPath.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable) UINavigationItem *navigationItemImplementation;
@property (nonatomic, strong, nullable) HUBComponentModelBuilderImplementation *headerComponentModelBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *bodyComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *overlayComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *bodyComponentIdentifierOrder;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *overlayComponentIdentifierOrder;

@end

@implementation HUBViewModelBuilderImplementation

#pragma mark - Property synthesization

@synthesize viewIdentifier = _viewIdentifier;
@synthesize customData = _customData;

#pragma mark - Initializer

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
        _bodyComponentModelBuilders = [NSMutableDictionary new];
        _overlayComponentModelBuilders = [NSMutableDictionary new];
        _bodyComponentIdentifierOrder = [NSMutableArray new];
        _overlayComponentIdentifierOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - HUBViewModelBuilder

- (BOOL)isEmpty
{
    if (self.headerComponentModelBuilderImplementation != nil) {
        return NO;
    }
    
    if (self.bodyComponentModelBuilders.count > 0) {
        return NO;
    }
    
    if (self.overlayComponentModelBuilders.count > 0) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)numberOfBodyComponentModelBuilders
{
    return self.bodyComponentModelBuilders.count;
}

- (NSUInteger)numberOfOverlayComponentModelBuilders
{
    return self.overlayComponentModelBuilders.count;
}

- (nullable NSString *)navigationBarTitle
{
    return self.navigationItemImplementation.title;
}

- (void)setNavigationBarTitle:(nullable NSString *)navigationBarTitle
{
    if (navigationBarTitle != nil) {
        self.navigationItem.title = navigationBarTitle;
        return;
    }
    
    self.navigationItemImplementation.title = nil;
}

- (UINavigationItem *)navigationItem
{
    if (self.navigationItemImplementation == nil) {
        self.navigationItemImplementation = [UINavigationItem new];
    }
    
    UINavigationItem * const navigationItem = self.navigationItemImplementation;
    return navigationItem;
}

- (id<HUBComponentModelBuilder>)headerComponentModelBuilder
{
    return [self getOrCreateBuilderForHeaderComponentModelWithIdentifier:nil];
}

- (BOOL)headerComponentModelBuilderExists
{
    return self.headerComponentModelBuilderImplementation != nil;
}

- (BOOL)builderExistsForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return self.bodyComponentModelBuilders[identifier] != nil;
}

- (BOOL)builderExistsForOverlayComponentModelWithIdentifier:(NSString *)identifier
{
    return self.overlayComponentModelBuilders[identifier] != nil;
}

- (NSArray<id<HUBComponentModelBuilder>> *)allBodyComponentModelBuilders
{
    NSMutableArray<id<HUBComponentModelBuilder>> * const builders = [NSMutableArray new];
    
    [self enumerateBodyComponentModelBuildersWithBlock:^BOOL(id<HUBComponentModelBuilder> builder) {
        [builders addObject:builder];
        return YES;
    }];
    
    return [builders copy];
}

- (NSArray<id<HUBComponentModelBuilder>> *)allOverlayComponentModelBuilders
{
    NSMutableArray<id<HUBComponentModelBuilder>> * const builders = [NSMutableArray new];
    
    [self enumerateOverlayComponentModelBuildersWithBlock:^BOOL(id<HUBComponentModelBuilder> builder) {
        [builders addObject:builder];
        return YES;
    }];
    
    return [builders copy];
}

- (id<HUBComponentModelBuilder>)builderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForBodyComponentModelWithIdentifier:identifier];
}

- (id<HUBComponentModelBuilder>)builderForOverlayComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForOverlayComponentModelWithIdentifier:identifier];
}

- (void)enumerateAllComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    NSParameterAssert(block != nil);
    
    if (self.headerComponentModelBuilderImplementation != nil) {
        id<HUBComponentModelBuilder> const headerComponentModelBuilder = self.headerComponentModelBuilderImplementation;
        
        if (!block(headerComponentModelBuilder)) {
            return;
        }
    }
    
    if (![self enumerateBodyComponentModelBuildersWithBlock:block]) {
        return;
    }
    
    [self enumerateOverlayComponentModelBuildersWithBlock:block];
}

- (void)removeHeaderComponentModelBuilder
{
    if (self.headerComponentModelBuilderImplementation == nil) {
        return;
    }
    
    self.headerComponentModelBuilderImplementation = nil;
}

- (void)removeBuilderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    if (self.bodyComponentModelBuilders[identifier] == nil) {
        return;
    }
    
    [self.bodyComponentModelBuilders removeObjectForKey:identifier];
    [self.bodyComponentIdentifierOrder removeObject:identifier];
}

- (void)removeBuilderForOverlayComponentModelWithIdentifier:(NSString *)identifier
{
    if (self.overlayComponentModelBuilders[identifier] == nil) {
        return;
    }
    
    [self.overlayComponentModelBuilders removeObjectForKey:identifier];
    [self.overlayComponentIdentifierOrder removeObject:identifier];
}

- (void)removeAllComponentModelBuilders
{
    [self removeHeaderComponentModelBuilder];
    
    [self.bodyComponentModelBuilders removeAllObjects];
    [self.bodyComponentIdentifierOrder removeAllObjects];
    
    [self.overlayComponentModelBuilders removeAllObjects];
    [self.overlayComponentIdentifierOrder removeAllObjects];
}

#pragma mark - API

- (id<HUBViewModel>)build
{
    id<HUBComponentModel> const headerComponentModel = [self.headerComponentModelBuilderImplementation buildForIndex:0 parent:nil];
    
    NSArray * const bodyComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.bodyComponentModelBuilders
                                                                                                    identifierOrder:self.bodyComponentIdentifierOrder
                                                                                                             parent:nil];
    
    NSArray * const overlayComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.overlayComponentModelBuilders
                                                                                                       identifierOrder:self.overlayComponentIdentifierOrder
                                                                                                                parent:nil];
    
    return [[HUBViewModelImplementation alloc] initWithIdentifier:self.viewIdentifier
                                                   navigationItem:self.navigationItemImplementation
                                             headerComponentModel:headerComponentModel
                                              bodyComponentModels:bodyComponentModels
                                           overlayComponentModels:overlayComponentModels
                                                       customData:[self.customData copy]];
}

#pragma mark - Manipulate custom data

- (void)setCustomDataValue:(nullable id)value forKey:(nonnull NSString *)key
{
    NSMutableDictionary *customData = [self.customData mutableCopy] ?: [[NSMutableDictionary alloc] init];

    if (value == nil) {
        [customData removeObjectForKey:key];
    } else {
        [customData setObject:(id)value forKey:key];
    }

    self.customData = customData;
}

#pragma mark - HUBJSONCompatibleBuilder

- (BOOL)addJSONData:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error
{
    NSError *JSONError = nil;
    NSObject *JSONObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONError];

    if (JSONObject == nil) {
        return HUBSetOutError(error, JSONError);
    }
    
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        [self addJSONDictionary:(NSDictionary *)JSONObject];
    } else if ([JSONObject isKindOfClass:[NSArray class]]) {
        [self addDataFromJSONArray:(NSArray *)JSONObject];
    } else {
        return HUBSetOutError(error, [NSError errorWithDomain:@"spotify.com.hubFramework.invalidJSON" code:0 userInfo:nil]);
    }
    
    return YES;
}

- (void)addJSONDictionary:(NSDictionary<NSString *,id> *)dictionary
{
    id<HUBViewModelJSONSchema> const viewModelSchema = self.JSONSchema.viewModelSchema;
    
    NSString * const viewIdentifier = [viewModelSchema.identifierPath stringFromJSONDictionary:dictionary];
    
    if (viewIdentifier != nil) {
        self.viewIdentifier = viewIdentifier;
    }
    
    NSString * const navigationBarTitle = [viewModelSchema.navigationBarTitlePath stringFromJSONDictionary:dictionary];
    
    if (navigationBarTitle != nil) {
        self.navigationBarTitle = navigationBarTitle;
    }
    
    NSDictionary * const customData = [viewModelSchema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (customData != nil) {
        NSDictionary * const existingCustomData = self.customData;
        
        if (existingCustomData != nil) {
            NSMutableDictionary * const mutableCustomData = [existingCustomData mutableCopy];
            [mutableCustomData addEntriesFromDictionary:customData];
            self.customData = [mutableCustomData copy];
        } else {
            self.customData = customData;
        }
    }
    
    NSDictionary * const headerComponentModelDictionary = [viewModelSchema.headerComponentModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (headerComponentModelDictionary != nil) {
        NSString * const headerComponentModelIdentifier = [self.JSONSchema.componentModelSchema.identifierPath stringFromJSONDictionary:headerComponentModelDictionary];
        HUBComponentModelBuilderImplementation * const headerComponentModelBuilder = [self getOrCreateBuilderForHeaderComponentModelWithIdentifier:headerComponentModelIdentifier];
        [headerComponentModelBuilder addJSONDictionary:headerComponentModelDictionary];
    }
    
    NSArray * const bodyComponentModelDictionaries = [viewModelSchema.bodyComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const componentModelDictionary in bodyComponentModelDictionaries) {
        [self addDataFromBodyComponentModelJSONDictionary:componentModelDictionary];
    }
    
    NSArray * const overlayComponentModelDictionaries = [viewModelSchema.overlayComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const componentModelDictionary in overlayComponentModelDictionaries) {
        NSString * const componentIdentifier = [self.JSONSchema.componentModelSchema.identifierPath stringFromJSONDictionary:componentModelDictionary];
        HUBComponentModelBuilderImplementation * const componentModelBuilder = [self getOrCreateBuilderForOverlayComponentModelWithIdentifier:componentIdentifier];
        [componentModelBuilder addJSONDictionary:componentModelDictionary];
    }
}

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBViewModelBuilder with contents: %@", HUBSerializeToString([self build])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBViewModelBuilderImplementation * const copy = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                 componentDefaults:self.componentDefaults
                                                                                                 iconImageResolver:self.iconImageResolver];
    
    if (self.navigationItemImplementation != nil) {
        HUBCopyNavigationItemProperties(copy.navigationItem, self.navigationItemImplementation);
    }
    
    copy.viewIdentifier = self.viewIdentifier;
    copy.customData = self.customData;
    copy.headerComponentModelBuilderImplementation = [self.headerComponentModelBuilderImplementation copy];
    
    for (NSString * const builderIdentifier in self.bodyComponentModelBuilders) {
        HUBComponentModelBuilderImplementation * const builderCopy = [self.bodyComponentModelBuilders[builderIdentifier] copy];
        copy.bodyComponentModelBuilders[builderIdentifier] = builderCopy;
    }
    
    for (NSString * const builderIdentifier in self.overlayComponentModelBuilders) {
        HUBComponentModelBuilderImplementation * const builderCopy = [self.overlayComponentModelBuilders[builderIdentifier] copy];
        copy.overlayComponentModelBuilders[builderIdentifier] = builderCopy;
    }
    
    [copy.bodyComponentIdentifierOrder addObjectsFromArray:self.bodyComponentIdentifierOrder];
    [copy.overlayComponentIdentifierOrder addObjectsFromArray:self.overlayComponentIdentifierOrder];
    
    return copy;
}

#pragma mark - Private utilities

- (void)addDataFromJSONArray:(NSArray<NSObject *> *)array
{
    for (NSObject * const object in array) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [self addDataFromBodyComponentModelJSONDictionary:(NSDictionary *)object];
        }
    }
}

- (void)addDataFromBodyComponentModelJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    NSString * const identifier = [self.JSONSchema.componentModelSchema.identifierPath stringFromJSONDictionary:dictionary];
    HUBComponentModelBuilderImplementation * const builder = [self getOrCreateBuilderForBodyComponentModelWithIdentifier:identifier];
    [builder addJSONDictionary:dictionary];
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForHeaderComponentModelWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = self.headerComponentModelBuilderImplementation;
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    if (identifier == nil) {
        identifier = @"header";
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [self createComponentModelBuilderWithIdentifier:identifier type:HUBComponentTypeHeader];
    self.headerComponentModelBuilderImplementation = newBuilder;
    return newBuilder;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForBodyComponentModelWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = [self existingComponentModelBuilderFromDictionary:self.bodyComponentModelBuilders
                                                                                                       modelIdentifier:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [self createComponentModelBuilderWithIdentifier:identifier type:HUBComponentTypeBody];
    self.bodyComponentModelBuilders[newBuilder.modelIdentifier] = newBuilder;
    [self.bodyComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForOverlayComponentModelWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = [self existingComponentModelBuilderFromDictionary:self.overlayComponentModelBuilders
                                                                                                       modelIdentifier:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [self createComponentModelBuilderWithIdentifier:identifier type:HUBComponentTypeOverlay];
    self.overlayComponentModelBuilders[newBuilder.modelIdentifier] = newBuilder;
    [self.overlayComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (nullable HUBComponentModelBuilderImplementation *)existingComponentModelBuilderFromDictionary:(NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *)dictionary
                                                                                 modelIdentifier:(nullable NSString *)modelIdentifier
{
    if (modelIdentifier == nil) {
        return nil;
    }
    
    NSString * const existingBuilderIdentifier = modelIdentifier;
    HUBComponentModelBuilderImplementation * const existingBuilder = dictionary[existingBuilderIdentifier];
    return existingBuilder;
}


- (HUBComponentModelBuilderImplementation *)createComponentModelBuilderWithIdentifier:(nullable NSString *)identifier
                                                                                 type:(HUBComponentType)type
{
    return [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                              type:type
                                                                        JSONSchema:self.JSONSchema
                                                                 componentDefaults:self.componentDefaults
                                                                 iconImageResolver:self.iconImageResolver
                                                              mainImageDataBuilder:nil
                                                        backgroundImageDataBuilder:nil];
}

- (BOOL)enumerateBodyComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    return [self enumerateComponentModelBuilders:self.bodyComponentModelBuilders
                                 identifierOrder:self.bodyComponentIdentifierOrder
                                       withBlock:block];
}

- (BOOL)enumerateOverlayComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    return [self enumerateComponentModelBuilders:self.overlayComponentModelBuilders
                                 identifierOrder:self.overlayComponentIdentifierOrder
                                       withBlock:block];
}

- (BOOL)enumerateComponentModelBuilders:(NSDictionary<NSString *, id<HUBComponentModelBuilder>> *)builders
                        identifierOrder:(NSArray<NSString *> *)identifierOrder
                              withBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    for (NSString * const identifier in identifierOrder) {
        id<HUBComponentModelBuilder> const builder = builders[identifier];
        
        if (!block(builder)) {
            return NO;
        }
    }
    
    return YES;
}

@end

NS_ASSUME_NONNULL_END
