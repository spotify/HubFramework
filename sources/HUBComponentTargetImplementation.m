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

#import "HUBComponentTargetImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBViewModel.h"
#import "HUBIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentTargetImplementation

@synthesize URI = _URI;
@synthesize initialViewModel = _initialViewModel;
@synthesize actionIdentifiers = _actionIdentifiers;
@synthesize customData = _customData;

#pragma mark - Initializer

- (instancetype)initWithURI:(nullable NSURL *)URI
           initialViewModel:(nullable id<HUBViewModel>)initialViewModel
          actionIdentifiers:(nullable NSArray<HUBIdentifier *> *)actionIdentifiers
                 customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
{
    self = [super init];
    
    if (self) {
        _URI = [URI copy];
        _initialViewModel = initialViewModel;
        _actionIdentifiers = actionIdentifiers;
        _customData = [customData copy];
    }
    
    return self;
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    
    serialization[HUBJSONKeyURI] = self.URI.absoluteString;
    serialization[HUBJSONKeyView] = [self.initialViewModel serialize];
    serialization[HUBJSONKeyActions] = [self serializeActionIdentifiers];
    serialization[HUBJSONKeyCustom] = self.customData;
    
    return [serialization copy];
}

#pragma mark - Private utilities

- (nullable NSArray<NSString *> *)serializeActionIdentifiers
{
    if (self.actionIdentifiers == nil) {
        return nil;
    }
    
    NSMutableArray<NSString *> * const serializedIdentifiers = [NSMutableArray new];
    
    for (HUBIdentifier * const identifier in self.actionIdentifiers) {
        [serializedIdentifiers addObject:identifier.identifierString];
    }
    
    return [serializedIdentifiers copy];
}

@end

NS_ASSUME_NONNULL_END
