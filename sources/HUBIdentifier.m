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

#import "HUBIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBIdentifier

#pragma mark - Initializers

- (instancetype)initWithNamespace:(NSString *)namespacePart name:(NSString *)namePart
{
    NSParameterAssert(namespacePart != nil);
    NSParameterAssert(namePart != nil);
    
    self = [super init];
    
    if (self) {
        _namespacePart = [namespacePart copy];
        _namePart = [namePart copy];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSString *)identifierString
{
    return [NSString stringWithFormat:@"%@:%@", self.namespacePart, self.namePart];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    return [[HUBIdentifier allocWithZone:zone] initWithNamespace:self.namespacePart
                                                            name:self.namePart];
}

#pragma mark - Equality and Hashing

- (BOOL)isEqualToIdentifier:(HUBIdentifier *)identifier
{
    if (![self.namespacePart isEqualToString:identifier.namespacePart]) {
        return NO;
    }
    
    return [self.namePart isEqualToString:identifier.namePart];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    
    if (![[other class] isEqual:[HUBIdentifier class]]) {
        return NO;
    }

    return [self isEqualToIdentifier:other];
}

- (NSUInteger)hash
{
    return self.namespacePart.hash ^ self.namePart.hash;
}

- (NSString *)description
{
    return self.identifierString;
}

@end

NS_ASSUME_NONNULL_END
