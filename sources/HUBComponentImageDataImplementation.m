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

#import "HUBComponentImageDataImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBIcon.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataImplementation

@synthesize identifier = _identifier;
@synthesize type = _type;
@synthesize URL = _URL;
@synthesize placeholderIcon = _placeholderIcon;
@synthesize localImage = _localImage;

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                              type:(HUBComponentImageType)type
                               URL:(nullable NSURL *)URL
                   placeholderIcon:(nullable id<HUBIcon>)placeholderIcon
                        localImage:(nullable UIImage *)localImage
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _type = type;
        _URL = [URL copy];
        _placeholderIcon = placeholderIcon;
        _localImage = localImage;
    }
    
    return self;
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyURI] = self.URL.absoluteString;
    serialization[HUBJSONKeyPlaceholder] = self.placeholderIcon.identifier;
    
    return [serialization copy];
}

@end

NS_ASSUME_NONNULL_END
