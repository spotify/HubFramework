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

#import "HUBIconImplementation.h"

#import "HUBIconImageResolver.h"
#import "HUBKeyPath.h"

@interface HUBIconImplementation ()

@property (nonatomic, strong, readonly) id<HUBIconImageResolver> imageResolver;
@property (nonatomic, assign, readonly) BOOL isPlaceholder;

@end

@implementation HUBIconImplementation

@synthesize identifier = _identifier;

#pragma mark - HUBAutoEquatable

+ (nullable NSSet<NSString *> *)ignoredAutoEquatablePropertyNames
{
    return [NSSet setWithObjects:HUBKeyPath((HUBIconImplementation *)nil, imageResolver), nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier imageResolver:(id<HUBIconImageResolver>)imageResolver isPlaceholder:(BOOL)isPlaceholder
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _imageResolver = imageResolver;
        _isPlaceholder = isPlaceholder;
    }
    
    return self;
}

#pragma mark - HUBIcon

- (nullable UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color
{
    if (self.isPlaceholder) {
        return [self.imageResolver imageForPlaceholderIconWithIdentifier:self.identifier size:size color:color];
    }
    return [self.imageResolver imageForComponentIconWithIdentifier:self.identifier size:size color:color];
}

@end
