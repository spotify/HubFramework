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

#import "HUBComponentModelImplementation.h"

#import "HUBIdentifier.h"
#import "HUBComponentImageData.h"
#import "HUBComponentTarget.h"
#import "HUBJSONKeys.h"
#import "HUBViewModel.h"
#import "HUBUtilities.h"
#import "HUBIcon.h"
#import "HUBKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelImplementation ()

@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSNumber *> *childIdentifierToIndexMap;
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSArray<id<HUBComponentModel>> *> *childrenByGroupIdentifier;

@end

@implementation HUBComponentModelImplementation

@synthesize identifier = _identifier;
@synthesize type = _type;
@synthesize index = _index;
@synthesize groupIdentifier = _groupIdentifier;
@synthesize componentIdentifier = _componentIdentifier;
@synthesize componentCategory = _componentCategory;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize accessoryTitle = _accessoryTitle;
@synthesize descriptionText = _descriptionText;
@synthesize mainImageData = _mainImageData;
@synthesize backgroundImageData = _backgroundImageData;
@synthesize customImageData = _customImageData;
@synthesize icon = _icon;
@synthesize target = _target;
@synthesize metadata = _metadata;
@synthesize loggingData = _loggingData;
@synthesize customData = _customData;
@synthesize parent = _parent;

#pragma mark - HUBAutoEquatable

+ (nullable NSSet<NSString *> *)ignoredAutoEquatablePropertyNames
{
    return [NSSet setWithObjects:HUBKeyPath((id<HUBComponentModel>)nil, parent),
        HUBKeyPath((id<HUBComponentModel>)nil, index),
        HUBKeyPath((id<HUBComponentModel>)nil, indexPath),
        nil];
}

#pragma mark - Initializer

- (instancetype)initWithIdentifier:(NSString *)identifier
                              type:(HUBComponentType)type
                             index:(NSUInteger)index
                   groupIdentifier:(nullable NSString *)groupIdentifier
               componentIdentifier:(HUBIdentifier *)componentIdentifier
                 componentCategory:(HUBComponentCategory)componentCategory
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                    accessoryTitle:(nullable NSString *)accessoryTitle
                   descriptionText:(nullable NSString *)descriptionText
                     mainImageData:(nullable id<HUBComponentImageData>)mainImageData
               backgroundImageData:(nullable id<HUBComponentImageData>)backgroundImageData
                   customImageData:(NSDictionary<NSString *, id<HUBComponentImageData>> *)customImageData
                              icon:(nullable id<HUBIcon>)icon
                            target:(nullable id<HUBComponentTarget>)target
                          metadata:(nullable NSDictionary<NSString *, id> *)metadata
                       loggingData:(nullable NSDictionary<NSString *, id> *)loggingData
                        customData:(nullable NSDictionary<NSString *, id> *)customData
                            parent:(nullable id<HUBComponentModel>)parent
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(componentIdentifier != nil);
    NSParameterAssert(componentCategory != nil);
    NSParameterAssert(customImageData != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _type = type;
        _componentIdentifier = [componentIdentifier copy];
        _componentCategory = [componentCategory copy];
        _index = index;
        _groupIdentifier = [groupIdentifier copy];
        _title = [title copy];
        _subtitle = [subtitle copy];
        _accessoryTitle = [accessoryTitle copy];
        _descriptionText = [descriptionText copy];
        _mainImageData = mainImageData;
        _backgroundImageData = backgroundImageData;
        _customImageData = customImageData;
        _icon = icon;
        _target = target;
        _metadata = metadata;
        _loggingData = loggingData;
        _customData = customData;
        _parent = parent;
    }
    
    return self;
}

#pragma mark - API

- (void)setChildren:(nullable NSArray<id<HUBComponentModel>> *)children
{
    _children = children;
    
    NSMutableDictionary<NSString *, NSNumber *> * const identifierToIndexMap = [NSMutableDictionary new];
    NSMutableDictionary<NSString *, NSMutableArray<id<HUBComponentModel>> *> *childrenByGroupIdentifier = [NSMutableDictionary new];
    
    for (id<HUBComponentModel> const child in children) {
        identifierToIndexMap[child.identifier] = @(child.index);
        
        if (child.groupIdentifier != nil) {
            NSString * const groupIdentifier = child.groupIdentifier;
            NSMutableArray<id<HUBComponentModel>> * const childrenInGroup = childrenByGroupIdentifier[groupIdentifier];
            
            if (childrenInGroup != nil) {
                [childrenInGroup addObject:child];
            } else {
                childrenByGroupIdentifier[groupIdentifier] = [NSMutableArray arrayWithObject:child];
            }
        }
    }
    
    self.childIdentifierToIndexMap = [identifierToIndexMap copy];
    
    if (childrenByGroupIdentifier.count > 0) {
        self.childrenByGroupIdentifier = [childrenByGroupIdentifier copy];
    }
}

#pragma mark - NSObject

- (nullable id)valueForKey:(NSString *)key
{
    // For some reason KVC won't work with this property name, so this workaround is required
    if ([key isEqualToString:@"componentCategory"]) {
        return self.componentCategory;
    }
    
    return [super valueForKey:key];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBComponentModel with contents: %@", HUBSerializeToString(self)];
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> const * serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyGroup] = self.groupIdentifier;
    serialization[HUBJSONKeyComponent] = [self serializedComponentData];
    serialization[HUBJSONKeyText] = [self serializedTextData];
    serialization[HUBJSONKeyImages] = [self serializedImageData];
    serialization[HUBJSONKeyTarget] = [self.target serialize];
    serialization[HUBJSONKeyMetadata] = self.metadata;
    serialization[HUBJSONKeyLogging] = self.loggingData;
    serialization[HUBJSONKeyCustom] = self.customData;
    serialization[HUBJSONKeyChildren] = [self serializedChildren];
    
    return [serialization copy];
}

#pragma mark - HUBComponentModel

- (NSIndexPath *)indexPath
{
    NSMutableArray<NSNumber *> * const indices = [NSMutableArray arrayWithObject:@(self.index)];

    id<HUBComponentModel> parent = self.parent;
    while (parent != nil) {
        // Add the next index at the start of the array as we're traversing up the hierarchy.
        [indices insertObject:@(parent.index) atIndex:0];
        parent = parent.parent;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:indices.firstObject.unsignedIntegerValue];
    for (NSUInteger i = 1; i < indices.count; i++) {
        indexPath = [indexPath indexPathByAddingIndex:indices[i].unsignedIntegerValue];
    }

    return indexPath;
}

- (nullable id<HUBComponentModel>)childAtIndex:(NSUInteger)childIndex
{
    if (childIndex >= self.children.count) {
        return nil;
    }
    
    return self.children[childIndex];
}

- (nullable id<HUBComponentModel>)childWithIdentifier:(NSString *)identifier
{
    NSNumber * const index = self.childIdentifierToIndexMap[identifier];
    
    if (index == nil) {
        return nil;
    }

    return self.children[index.unsignedIntegerValue];
}

- (nullable NSArray<id<HUBComponentModel>> *)childrenInGroupWithIdentifier:(NSString *)groupIdentifier
{
    return self.childrenByGroupIdentifier[groupIdentifier];
}

#pragma mark - Private utilities

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedComponentData
{
    return @{
        HUBJSONKeyIdentifier: self.componentIdentifier.identifierString,
        HUBJSONKeyCategory: self.componentCategory
    };
}

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedTextData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyTitle] = self.title;
    serialization[HUBJSONKeySubtitle] = self.subtitle;
    serialization[HUBJSONKeyAccessory] = self.accessoryTitle;
    serialization[HUBJSONKeyDescription] = self.descriptionText;
    
    if (serialization.count == 0) {
        return nil;
    }
    
    return [serialization copy];
}

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedImageData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyMain] = [self.mainImageData serialize];
    serialization[HUBJSONKeyBackground] = [self.backgroundImageData serialize];
    serialization[HUBJSONKeyIcon] = self.icon.identifier;
    
    NSMutableDictionary * const customImageDataDictionary = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageData) {
        customImageDataDictionary[imageIdentifier] = [self.customImageData[imageIdentifier] serialize];
    }
    
    if (customImageDataDictionary.count > 0) {
        serialization[HUBJSONKeyCustom] = [customImageDataDictionary copy];
    }
    
    if (serialization.count == 0) {
        return nil;
    }
    
    return [serialization copy];
}

- (nullable NSArray<NSDictionary<NSString *, NSObject<NSCoding> *> *> *)serializedChildren
{
    NSArray<id<HUBComponentModel>> * const children = self.children;
    
    if (children.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSDictionary<NSString *, NSObject<NSCoding> *> *> * const serializedChildren = [NSMutableArray new];
    
    for (id<HUBComponentModel> const child in children) {
        [serializedChildren addObject:[child serialize]];
    }
    
    return [serializedChildren copy];
}

@end

NS_ASSUME_NONNULL_END
