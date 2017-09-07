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

#import "HUBAutoEquatable.h"

#import <objc/runtime.h>

#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^HUBAutoEquatableComparisonBlock)(NSObject *, NSObject *);
typedef NSDictionary<NSString *, HUBAutoEquatableComparisonBlock> HUBAutoEquatableComparisonMap;
typedef NSMutableDictionary<NSString *, HUBAutoEquatableComparisonBlock> HUBAutoEquatableMutableComparisonMap;

@implementation HUBAutoEquatable

#pragma mark - Class methods

+ (nullable NSSet<NSString *> *)ignoredAutoEquatablePropertyNames
{
    return nil;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    HUBAutoEquatableComparisonMap * const comparisonMap = [self getOrCreateComparisonMap];
    
    for (NSString * const propertyName in comparisonMap) {
        if (!comparisonMap[propertyName](self, object)) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Private utilities

- (HUBAutoEquatableComparisonMap *)getOrCreateComparisonMap
{
    static NSMutableDictionary<NSString *, HUBAutoEquatableComparisonMap *> *comparisonMapsForClassNames = nil;
    
    if (comparisonMapsForClassNames == nil) {
        comparisonMapsForClassNames = [NSMutableDictionary new];
    }
    
    NSString * const className = NSStringFromClass([self class]);
    
    HUBAutoEquatableComparisonMap *comparisonMap = comparisonMapsForClassNames[className];
    
    if (comparisonMap == nil) {
        NSSet<NSString *> * const ignoredPropertyNames = [[self class] ignoredAutoEquatablePropertyNames];
        HUBAutoEquatableMutableComparisonMap * const mutableComparisonMap = [HUBAutoEquatableMutableComparisonMap new];
        
        unsigned int propertyCount;
        objc_property_t *propertyList = class_copyPropertyList([self class], &propertyCount);
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            const objc_property_t property = propertyList[i];
            const char * propertyNameCString = property_getName(property);
            NSString * const propertyName = [NSString stringWithUTF8String:propertyNameCString];
            
            if (protocol_getProperty(@protocol(NSObject), propertyNameCString, YES, YES) != NULL) {
                continue;
            }
            
            if ([ignoredPropertyNames containsObject:propertyName]) {
                continue;
            }
            
            mutableComparisonMap[propertyName] = ^(NSObject * const objectA, NSObject * const objectB) {
                return HUBPropertyIsEqual(objectA, objectB, propertyName);
            };
        }

        if (propertyList) {
            free(propertyList);
        }
        
        comparisonMap = mutableComparisonMap;
        comparisonMapsForClassNames[className] = comparisonMap;
    }
    
    return comparisonMap;
}

@end

NS_ASSUME_NONNULL_END
