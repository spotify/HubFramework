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

#import "HUBComponentModelBuilderImplementation.h"

#import "HUBIdentifier.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBComponentTargetBuilderImplementation.h"
#import "HUBComponentTargetImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentModelJSONSchema.h"
#import "HUBJSONPath.h"
#import "HUBComponentDefaults.h"
#import "HUBIconImplementation.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderImplementation ()

@property (nonatomic, assign, readonly) HUBComponentType type;
@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *mainImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *backgroundImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentImageDataBuilderImplementation *> *customImageDataBuilders;
@property (nonatomic, strong, nullable) HUBComponentTargetBuilderImplementation *targetBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *childBuilders;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *childIdentifierOrder;

@end

@implementation HUBComponentModelBuilderImplementation

#pragma mark - Property synthesization

@synthesize modelIdentifier = _modelIdentifier;
@synthesize preferredIndex = _preferredIndex;
@synthesize groupIdentifier = _groupIdentifier;
@synthesize componentNamespace = _componentNamespace;
@synthesize componentName = _componentName;
@synthesize componentCategory = _componentCategory;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize accessoryTitle = _accessoryTitle;
@synthesize descriptionText = _descriptionText;
@synthesize iconIdentifier = _iconIdentifier;
@synthesize metadata = _metadata;
@synthesize loggingData = _loggingData;
@synthesize customData = _customData;

#pragma mark - Class methods

+ (NSArray<id<HUBComponentModel>> *)buildComponentModelsUsingBuilders:(NSDictionary<NSString *,HUBComponentModelBuilderImplementation *> *)builders
                                                      identifierOrder:(NSArray<NSString *> *)identifierOrder
                                                               parent:(nullable id<HUBComponentModel>)parent
{
    NSMutableOrderedSet<HUBComponentModelBuilderImplementation *> * const sortedBuilders = [NSMutableOrderedSet new];
    NSMutableDictionary<NSNumber *, HUBComponentModelBuilderImplementation *> * const buildersByPreferredIndex = [NSMutableDictionary new];
    
    for (NSString * const identifier in identifierOrder) {
        HUBComponentModelBuilderImplementation * const builder = builders[identifier];
        
        if (builder == nil) {
            continue;
        }
        
        NSNumber * const preferredIndex = builder.preferredIndex;
        
        if (preferredIndex != nil) {
            buildersByPreferredIndex[preferredIndex] = builder;
        }
        
        [sortedBuilders addObject:builder];
    }

    NSArray *sortedPreferredIndexes = [[buildersByPreferredIndex allKeys] sortedArrayUsingSelector: @selector(compare:)];
    for (NSNumber * const preferredIndex in sortedPreferredIndexes) {
        HUBComponentModelBuilderImplementation * const builder = buildersByPreferredIndex[preferredIndex];
        NSUInteger decodedPreferredIndex = preferredIndex.unsignedIntegerValue;
        
        [sortedBuilders removeObject:builder];
        
        if (decodedPreferredIndex >= sortedBuilders.count) {
            [sortedBuilders addObject:builder];
        } else {
            [sortedBuilders insertObject:builder atIndex:decodedPreferredIndex];
        }
    }
    
    NSMutableArray<id<HUBComponentModel>> * const models = [NSMutableArray new];
    
    for (HUBComponentModelBuilderImplementation * const builder in sortedBuilders) {
        id<HUBComponentModel> const model = [builder buildForIndex:models.count parent:parent];
        [models addObject:model];
    }
    
    return [models copy];
}

#pragma mark - Initializer

- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                                   type:(HUBComponentType)type
                             JSONSchema:(id<HUBJSONSchema>)JSONSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                   mainImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)mainImageDataBuilder
             backgroundImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)backgroundImageDataBuilder
{
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    if (modelIdentifier == nil) {
        modelIdentifier = [NSString stringWithFormat:@"UnknownComponent:%@", [NSUUID UUID].UUIDString];
    }
    
    self = [super init];
    
    if (self) {
        _type = type;
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
        
        _modelIdentifier = (NSString *)modelIdentifier;
        _componentNamespace = [componentDefaults.componentNamespace copy];
        _componentName = [componentDefaults.componentName copy];
        _componentCategory = [componentDefaults.componentCategory copy];
        
        if (mainImageDataBuilder != nil) {
            HUBComponentImageDataBuilderImplementation * const nonNilMainImageDataBuilder = mainImageDataBuilder;
            _mainImageDataBuilderImplementation = nonNilMainImageDataBuilder;
        } else {
            _mainImageDataBuilderImplementation = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                                                       iconImageResolver:iconImageResolver];
        }
        
        if (backgroundImageDataBuilder != nil) {
            HUBComponentImageDataBuilderImplementation * const nonNilBackgroundImageDataBuilder = backgroundImageDataBuilder;
            _backgroundImageDataBuilderImplementation = nonNilBackgroundImageDataBuilder;
        } else {
            _backgroundImageDataBuilderImplementation = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                                                             iconImageResolver:iconImageResolver];
        }
        
        _customImageDataBuilders = [NSMutableDictionary new];
        _childBuilders = [NSMutableDictionary new];
        _childIdentifierOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - HUBComponentModelBuilder

- (id<HUBComponentImageDataBuilder>)mainImageDataBuilder
{
    return self.mainImageDataBuilderImplementation;
}

- (nullable NSURL *)mainImageURL
{
    return self.mainImageDataBuilder.URL;
}

- (void)setMainImageURL:(nullable NSURL *)mainImageURL
{
    self.mainImageDataBuilder.URL = mainImageURL;
}

- (nullable UIImage *)mainImage
{
    return self.mainImageDataBuilder.localImage;
}

- (void)setMainImage:(nullable UIImage *)mainImage
{
    self.mainImageDataBuilder.localImage = mainImage;
}

- (id<HUBComponentImageDataBuilder>)backgroundImageDataBuilder
{
    return self.backgroundImageDataBuilderImplementation;
}

- (id<HUBComponentTargetBuilder>)targetBuilder
{
    return [self getOrCreateTargetBuilder];
}

- (nullable NSURL *)backgroundImageURL
{
    return self.backgroundImageDataBuilder.URL;
}

- (void)setBackgroundImageURL:(nullable NSURL *)backgroundImageURL
{
    self.backgroundImageDataBuilder.URL = backgroundImageURL;
}

- (nullable UIImage *)backgroundImage
{
    return self.backgroundImageDataBuilder.localImage;
}

- (void)setBackgroundImage:(nullable UIImage *)backgroundImage
{
    self.backgroundImageDataBuilder.localImage = backgroundImage;
}

- (BOOL)builderExistsForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return self.customImageDataBuilders[identifier] != nil;
}

- (id<HUBComponentImageDataBuilder>)builderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForCustomImageDataWithIdentifier:identifier];
}

- (NSArray<id<HUBComponentModelBuilder>> *)allChildBuilders
{
    NSMutableArray<id<HUBComponentModelBuilder>> * const builders = [NSMutableArray new];

    for (NSString * const identifier in self.childIdentifierOrder) {
        id<HUBComponentModelBuilder> const builder = self.childBuilders[identifier];
        [builders addObject:builder];
    }

    return [builders copy];
}

- (BOOL)builderExistsForChildWithIdentifier:(NSString *)identifier
{
    return self.childBuilders[identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForChildWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForChildWithIdentifier:identifier];
}

- (void)removeBuilderForChildWithIdentifier:(NSString *)identifier
{
    self.childBuilders[identifier] = nil;
    [self.childIdentifierOrder removeObject:identifier];
}

- (void)removeAllChildBuilders
{
    [self.childBuilders removeAllObjects];
    [self.childIdentifierOrder removeAllObjects];
}

#pragma mark - HUBJSONCompatibleBuilder

- (nullable NSError *)addJSONData:(NSData *)JSONData
{
    return HUBAddJSONDataToBuilder(JSONData, self);
}

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBComponentModelJSONSchema> componentModelSchema = self.JSONSchema.componentModelSchema;
    
    NSString * const componentIdentifierString = [componentModelSchema.componentIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (componentIdentifierString != nil) {
        NSArray * const componentIdentifierParts = [componentIdentifierString componentsSeparatedByString:@":"];
        
        if (componentIdentifierParts.count > 1) {
            self.componentNamespace = componentIdentifierParts[0];
            self.componentName = componentIdentifierParts[1];
        } else if (componentIdentifierParts.count == 1) {
            self.componentName = componentIdentifierParts[0];
        }
    }
    
    NSString * const groupIdentifier = [componentModelSchema.groupIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (groupIdentifier != nil) {
        self.groupIdentifier = groupIdentifier;
    }
    
    NSString * const componentCategory = [componentModelSchema.componentCategoryPath stringFromJSONDictionary:dictionary];
    
    if (componentCategory != nil) {
        self.componentCategory = componentCategory;
    }
    
    NSString * const title = [componentModelSchema.titlePath stringFromJSONDictionary:dictionary];
    
    if (title != nil) {
        self.title = title;
    }
    
    NSString * const subtitle = [componentModelSchema.subtitlePath stringFromJSONDictionary:dictionary];
    
    if (subtitle != nil) {
        self.subtitle = subtitle;
    }
    
    NSString * const accessoryTitle = [componentModelSchema.accessoryTitlePath stringFromJSONDictionary:dictionary];
    
    if (accessoryTitle != nil) {
        self.accessoryTitle = accessoryTitle;
    }
    
    NSString * const descriptionText = [componentModelSchema.descriptionTextPath stringFromJSONDictionary:dictionary];
    
    if (descriptionText != nil) {
        self.descriptionText = descriptionText;
    }
    
    NSDictionary * const targetDictionary = [componentModelSchema.targetDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (targetDictionary != nil) {
        [[self getOrCreateTargetBuilder] addDataFromJSONDictionary:targetDictionary];
    }
    
    NSDictionary * const metadata = [componentModelSchema.metadataPath dictionaryFromJSONDictionary:dictionary];
    
    if (metadata != nil) {
        self.metadata = HUBMergeDictionaries(self.metadata, metadata);
    }
    
    NSDictionary * const loggingData = [componentModelSchema.loggingDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (loggingData != nil) {
        self.loggingData = HUBMergeDictionaries(self.loggingData, loggingData);
    }
    
    NSDictionary * const customData = [componentModelSchema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (customData != nil) {
        self.customData = HUBMergeDictionaries(self.customData, customData);
    }
    
    NSDictionary * const mainImageDataDictionary = [componentModelSchema.mainImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (mainImageDataDictionary != nil) {
        [self.mainImageDataBuilderImplementation addDataFromJSONDictionary:mainImageDataDictionary];
    }
    
    NSDictionary * const backgroundImageDataDictionary = [componentModelSchema.backgroundImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (backgroundImageDataDictionary != nil) {
        [self.backgroundImageDataBuilderImplementation addDataFromJSONDictionary:backgroundImageDataDictionary];
    }
    
    NSDictionary * const customImageDataDictionary = [componentModelSchema.customImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    for (NSString * const imageIdentifier in customImageDataDictionary) {
        NSDictionary * const imageDataDictionary = customImageDataDictionary[imageIdentifier];
        
        if ([imageDataDictionary isKindOfClass:[NSDictionary class]]) {
            HUBComponentImageDataBuilderImplementation * const builder = [self getOrCreateBuilderForCustomImageDataWithIdentifier:imageIdentifier];
            [builder addDataFromJSONDictionary:imageDataDictionary];
        }
    }
    
    NSString * const iconIdentifier = [componentModelSchema.iconIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (iconIdentifier != nil) {
        self.iconIdentifier = iconIdentifier;
    }
    
    NSArray * const childDictionaries = [componentModelSchema.childDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const childDictionary in childDictionaries) {
        NSString * const childModelIdentifier = [componentModelSchema.identifierPath stringFromJSONDictionary:childDictionary];
        HUBComponentModelBuilderImplementation * const childModelBuilder = [self getOrCreateBuilderForChildWithIdentifier:childModelIdentifier];
        [childModelBuilder addDataFromJSONDictionary:childDictionary];
    }
}

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBComponentModelBuilder with contents: %@",
            HUBSerializeToString([self buildForIndex:self.preferredIndex.unsignedIntegerValue parent:nil])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBComponentImageDataBuilderImplementation * const mainImageDataBuilder = [self.mainImageDataBuilderImplementation copy];
    HUBComponentImageDataBuilderImplementation * const backgroundImageDataBuilder = [self.backgroundImageDataBuilderImplementation copy];
    
    HUBComponentModelBuilderImplementation * const copy = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:self.modelIdentifier
                                                                                                                             type:self.type
                                                                                                                       JSONSchema:self.JSONSchema
                                                                                                                componentDefaults:self.componentDefaults
                                                                                                                iconImageResolver:self.iconImageResolver
                                                                                                             mainImageDataBuilder:mainImageDataBuilder
                                                                                                       backgroundImageDataBuilder:backgroundImageDataBuilder];
    
    copy.componentNamespace = self.componentNamespace;
    copy.componentName = self.componentName;
    copy.componentCategory = self.componentCategory;
    copy.preferredIndex = self.preferredIndex;
    copy.groupIdentifier = self.groupIdentifier;
    copy.title = self.title;
    copy.subtitle = self.subtitle;
    copy.accessoryTitle = self.accessoryTitle;
    copy.descriptionText = self.descriptionText;
    copy.iconIdentifier = self.iconIdentifier;
    copy.targetBuilderImplementation = [self.targetBuilderImplementation copy];
    copy.customData = self.customData;
    copy.metadata = self.metadata;
    copy.loggingData = self.loggingData;
    
    for (NSString * const customImageIdentifier in self.customImageDataBuilders) {
        copy.customImageDataBuilders[customImageIdentifier] = [self.customImageDataBuilders[customImageIdentifier] copy];
    }
    
    for (NSString * const childIdentifier in self.childBuilders) {
        copy.childBuilders[childIdentifier] = [self.childBuilders[childIdentifier] copy];
    }
    
    [copy.childIdentifierOrder addObjectsFromArray:self.childIdentifierOrder];
    
    return copy;
}

#pragma mark - API

- (id<HUBComponentModel>)buildForIndex:(NSUInteger)index parent:(nullable id<HUBComponentModel>)parent
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:self.componentNamespace
                                                                                    name:self.componentName];
    
    id<HUBComponentImageData> const mainImageData = [self.mainImageDataBuilderImplementation buildWithIdentifier:nil
                                                                                                            type:HUBComponentImageTypeMain];
    
    id<HUBComponentImageData> const backgroundImageData = [self.backgroundImageDataBuilderImplementation buildWithIdentifier:nil
                                                                                                                        type:HUBComponentImageTypeBackground];
    
    NSMutableDictionary * const customImageData = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageDataBuilders) {
        HUBComponentImageDataBuilderImplementation * const builder = self.customImageDataBuilders[imageIdentifier];
        id<HUBComponentImageData> const imageData = [builder buildWithIdentifier:imageIdentifier type:HUBComponentImageTypeCustom];
        
        if (imageData != nil) {
            [customImageData setObject:imageData forKey:imageIdentifier];
        }
    }
    
    id<HUBIcon> const icon = [self buildIconForPlaceholder:NO];
    id<HUBComponentTarget> const target = [self.targetBuilderImplementation build];
    
    HUBComponentModelImplementation * const model = [[HUBComponentModelImplementation alloc] initWithIdentifier:self.modelIdentifier
                                                                                                           type:self.type
                                                                                                          index:index
                                                                                                groupIdentifier:self.groupIdentifier
                                                                                            componentIdentifier:componentIdentifier
                                                                                              componentCategory:self.componentCategory
                                                                                                          title:self.title
                                                                                                       subtitle:self.subtitle
                                                                                                 accessoryTitle:self.accessoryTitle
                                                                                                descriptionText:self.descriptionText
                                                                                                  mainImageData:mainImageData
                                                                                            backgroundImageData:backgroundImageData
                                                                                                customImageData:customImageData
                                                                                                           icon:icon
                                                                                                         target:target
                                                                                                       metadata:self.metadata
                                                                                                    loggingData:self.loggingData
                                                                                                     customData:self.customData
                                                                                                         parent:parent];
    
    model.children = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.childBuilders
                                                                               identifierOrder:self.childIdentifierOrder
                                                                                        parent:model];
    
    return model;
}

#pragma mark - Private utilities

- (HUBComponentTargetBuilderImplementation *)getOrCreateTargetBuilder
{
    if (self.targetBuilderImplementation == nil) {
        self.targetBuilderImplementation = [[HUBComponentTargetBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                             componentDefaults:self.componentDefaults
                                                                                             iconImageResolver:self.iconImageResolver
                                                                                             actionIdentifiers:nil];
    }
    
    HUBComponentTargetBuilderImplementation * const targetBuilder = self.targetBuilderImplementation;
    return targetBuilder;
}

- (HUBComponentImageDataBuilderImplementation *)getOrCreateBuilderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    HUBComponentImageDataBuilderImplementation * const existingBuilder = self.customImageDataBuilders[identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentImageDataBuilderImplementation * const newBuilder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                                         iconImageResolver:self.iconImageResolver];
    
    [self.customImageDataBuilders setObject:newBuilder forKey:identifier];
    
    return newBuilder;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForChildWithIdentifier:(nullable NSString *)identifier
{
    if (identifier != nil) {
        NSString * const existingBuilderIdentifier = identifier;
        HUBComponentModelBuilderImplementation * const existingBuilder = self.childBuilders[existingBuilderIdentifier];
        
        if (existingBuilder != nil) {
            return existingBuilder;
        }
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                                                                                   type:self.type
                                                                                                                             JSONSchema:self.JSONSchema
                                                                                                                      componentDefaults:self.componentDefaults
                                                                                                                      iconImageResolver:self.iconImageResolver
                                                                                                                   mainImageDataBuilder:nil
                                                                                                             backgroundImageDataBuilder:nil];
    
    self.childBuilders[newBuilder.modelIdentifier] = newBuilder;
    [self.childIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (nullable id<HUBIcon>)buildIconForPlaceholder:(BOOL)forPlaceholder
{
    id<HUBIconImageResolver> const iconImageResolver = self.iconImageResolver;
    
    if (iconImageResolver == nil) {
        return nil;
    }
    
    NSString * const iconIdentifier = self.iconIdentifier;
    
    if (iconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBIconImplementation alloc] initWithIdentifier:iconIdentifier imageResolver:iconImageResolver isPlaceholder:forPlaceholder];
}

@end

NS_ASSUME_NONNULL_END
