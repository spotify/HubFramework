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

#import "HUBViewModelImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBComponentModel.h"
#import "HUBUtilities.h"
#import "HUBKeyPath.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelImplementation

@synthesize identifier = _identifier;
@synthesize navigationItem = _navigationItem;
@synthesize headerComponentModel = _headerComponentModel;
@synthesize bodyComponentModels = _bodyComponentModels;
@synthesize overlayComponentModels = _overlayComponentModels;
@synthesize customData = _customData;
@synthesize buildDate = _buildDate;

#pragma mark - HUBAutoEquatable

+ (nullable NSSet<NSString *> *)ignoredAutoEquatablePropertyNames
{
    return [NSSet setWithObjects:HUBKeyPath((id<HUBViewModel>)nil, buildDate),
                                 HUBKeyPath((id<HUBViewModel>)nil, navigationItem),
                                 nil];
}

#pragma mark - Initializer

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                    navigationItem:(nullable UINavigationItem *)navigationItem
              headerComponentModel:(nullable id<HUBComponentModel>)headerComponentModel
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
            overlayComponentModels:(NSArray<id<HUBComponentModel>> *)overlayComponentModels
                        customData:(nullable NSDictionary<NSString *, id> *)customData
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _headerComponentModel = headerComponentModel;
        _bodyComponentModels = bodyComponentModels;
        _overlayComponentModels = overlayComponentModels;
        _customData = customData;
        _buildDate = [NSDate date];
        
        if (navigationItem != nil) {
            _navigationItem = HUBCopyNavigationItemProperties([UINavigationItem new], navigationItem);
        }
    }
    
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    BOOL const superValue = [super isEqual:object];
    
    if (!superValue) {
        return NO;
    }
    
    HUBViewModelImplementation * const viewModel = object;
    
    if (self.navigationItem == nil || viewModel.navigationItem == nil) {
        return (self.navigationItem == nil && viewModel.navigationItem == nil);
    }
    
    UINavigationItem * const navigationItem = self.navigationItem;
    UINavigationItem * const otherNavigationItem = viewModel.navigationItem;
    return HUBNavigationItemEqualToNavigationItem(navigationItem, otherNavigationItem);
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBViewModel with contents: %@", HUBSerializeToString(self)];
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyTitle] = self.navigationItem.title;
    serialization[HUBJSONKeyHeader] = [self.headerComponentModel serialize];
    serialization[HUBJSONKeyBody] = [self serializeComponentModels:self.bodyComponentModels];
    serialization[HUBJSONKeyOverlays] = [self serializeComponentModels:self.overlayComponentModels];
    serialization[HUBJSONKeyCustom] = self.customData;
    
    return [serialization copy];
}

#pragma mark - Private utilities

- (nullable NSArray<NSDictionary<NSString *, NSObject *> *> *)serializeComponentModels:(NSArray<id<HUBComponentModel>> *)componentModels
{
    if (componentModels.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSDictionary<NSString *, NSObject *> *> * const serializedModels = [NSMutableArray new];
    
    for (id<HUBComponentModel> const model in componentModels) {
        [serializedModels addObject:[model serialize]];
    }
    
    return [serializedModels copy];
}

@end

NS_ASSUME_NONNULL_END
