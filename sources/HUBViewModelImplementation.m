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

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelImplementation

@synthesize identifier = _identifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize headerComponentModel = _headerComponentModel;
@synthesize bodyComponentModels = _bodyComponentModels;
@synthesize overlayComponentModels = _overlayComponentModels;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;
@synthesize buildDate = _buildDate;

#pragma mark - HUBAutoEquatable

+ (nullable NSSet<NSString *> *)ignoredAutoEquatablePropertyNames
{
    return [NSSet setWithObject:NSStringFromSelector(@selector(buildDate))];
}

#pragma mark - Initializer

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                navigationBarTitle:(nullable NSString *)navigationBarTitle
              headerComponentModel:(nullable id<HUBComponentModel>)headerComponentModel
               bodyComponentModels:(NSArray<id<HUBComponentModel>> *)bodyComponentModels
            overlayComponentModels:(NSArray<id<HUBComponentModel>> *)overlayComponentModels
                      extensionURL:(nullable NSURL *)extensionURL
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _navigationBarTitle = [navigationBarTitle copy];
        _headerComponentModel = headerComponentModel;
        _bodyComponentModels = bodyComponentModels;
        _overlayComponentModels = overlayComponentModels;
        _extensionURL = [extensionURL copy];
        _customData = customData;
        _buildDate = [NSDate date];
    }
    
    return self;
}

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBViewModel with contents: %@", HUBSerializeToString(self)];
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyTitle] = self.navigationBarTitle;
    serialization[HUBJSONKeyHeader] = [self.headerComponentModel serialize];
    serialization[HUBJSONKeyBody] = [self serializeComponentModels:self.bodyComponentModels];
    serialization[HUBJSONKeyOverlays] = [self serializeComponentModels:self.overlayComponentModels];
    serialization[HUBJSONKeyExtension] = self.extensionURL.absoluteString;
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
