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

#import <UIKit/UIKit.h>

#import "HUBComponent.h"
#import "HUBErrors.h"
#import "HUBJSONCompatibleBuilder.h"
#import "HUBKeyPath.h"
#import "HUBSerializable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Return whether two properties are considered equal
 *
 *  @param objectA The first object
 *  @param objectB The second object
 *  @param propertyName The name of the property to compare
 *
 *  Two nil values are considered equal.
 */
static inline BOOL HUBPropertyIsEqual(NSObject * _Nullable objectA, NSObject * _Nullable objectB, NSString *propertyName)
{
    NSObject * const valueA = [objectA valueForKey:propertyName];
    NSObject * const valueB = [objectB valueForKey:propertyName];
    
    if (valueA == nil && valueB == nil) {
        return YES;
    }
    
    return [valueA isEqual:valueB];
}

/**
 *  Load the view for a component if it hasn't been loaded already
 *
 *  @param component The component to load a view for
 *
 *  This function asserts that a view has been loaded after -loadView was sent to the component.
 */
static inline UIView *HUBComponentLoadViewIfNeeded(id<HUBComponent> component)
{
    if (component.view == nil) {
        [component loadView];
    }
    
    UIView * const view = component.view;
    NSCAssert(view, @"All components are required to load a view in -loadView");
    return view;
}

/**
 *  Conditionally sets the given optional `outError` to the `error`.
 *
 *  The function always returns `NO`.
 *
 *  @param outError The pointer to an `NSError` pointer which should be assigned to.
 *  @param error The error that should be assigned to the `outError`.
 *
 *  @return `NO`.
 */
static inline BOOL HUBSetOutError(NSError * _Nullable __autoreleasing *outError, NSError *error) __attribute__((const));
static inline BOOL HUBSetOutError(NSError * _Nullable __autoreleasing *outError, NSError *error)
{
    if (outError) {
        *outError = error;
    }
    return NO;
}

/**
 *  Add binary JSON data to a JSON compatible builder
 *
 *  @param data The binary data to add to the builder. Must contain dictionary-based JSON.
 *  @param builder The builder to add the data to.
 *  @param outError Contains an `NSError` object that describes the problem, iff an error occurred when parsing the
 *                  supplied JSON data.
 *
 *  @return `YES` if the data was successfully serialized and added; otherwise `NO`.
 */
static inline BOOL HUBAddJSONDataToBuilder(NSData *data,
                                           id<HUBJSONCompatibleBuilder> builder,
                                           NSError * _Nullable __autoreleasing *outError)
{
    if (data.length == 0) {
        return HUBSetOutError(outError, [NSError errorWithDomain:HUBJSONSerializationErrorDomain code:HUBJSONSerializationErrorCodeEmptyData userInfo:nil]);
    }

    NSError *JSONError;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&JSONError];

    if (JSONObject == nil && JSONError != nil) {
        return HUBSetOutError(outError, JSONError);
    }

    if (![JSONObject isKindOfClass:[NSDictionary class]]) {
        return HUBSetOutError(outError, [NSError errorWithDomain:HUBJSONSerializationErrorDomain code:HUBJSONSerializationErrorCodeInvalidJSON userInfo:nil]);
    }
    
    [builder addJSONDictionary:(NSDictionary *)JSONObject];
    
    return YES;
}

/**
 *  Merge two dictionaries and return the result
 *
 *  @param dictionaryA The first dictionary
 *  @param dictionaryB The second dictionary
 *
 *  If either of the dictionaries is `nil`, then the other dictionary is returned unmodified. Otherwise, the entries from `dictionaryB`
 *  will be added to `dictionaryA`, overriding any values that have duplicate keys in both dictionaries.
 */
static inline NSDictionary<NSString *, id> * _Nullable HUBMergeDictionaries(NSDictionary<NSString *, id> * _Nullable dictionaryA,
                                                                            NSDictionary<NSString *, id> * _Nullable dictionaryB)
{
    if (dictionaryA == nil) {
        return dictionaryB;
    }
    
    if (dictionaryB == nil) {
        return dictionaryA;
    }
    
    NSMutableDictionary<NSString *, id> * const mergedDictionary = [dictionaryA mutableCopy];
    [mergedDictionary addEntriesFromDictionary:(NSDictionary *)dictionaryB];
    return [mergedDictionary copy];
}

/**
 *  Return the property names that should be taken into account when handling a `UINavigationItem`
 *
 *  This function is used to determine which properties should be compared or copied. Note that
 *  `HUBAutoEquatable` is not used here, since we don't control the implementation of the class.
 */
static inline NSArray<NSString *> *HUBNavigationItemPropertyNames()
{
    #if TARGET_OS_TV
    return @[
        HUBKeyPath((UINavigationItem *)nil, title),
        HUBKeyPath((UINavigationItem *)nil, titleView),
        HUBKeyPath((UINavigationItem *)nil, leftBarButtonItems),
        HUBKeyPath((UINavigationItem *)nil, rightBarButtonItems),
    ];
    #else
    return @[
        HUBKeyPath((UINavigationItem *)nil, title),
        HUBKeyPath((UINavigationItem *)nil, titleView),
        HUBKeyPath((UINavigationItem *)nil, prompt),
        HUBKeyPath((UINavigationItem *)nil, backBarButtonItem),
        HUBKeyPath((UINavigationItem *)nil, hidesBackButton),
        HUBKeyPath((UINavigationItem *)nil, leftBarButtonItems),
        HUBKeyPath((UINavigationItem *)nil, rightBarButtonItems),
        HUBKeyPath((UINavigationItem *)nil, leftItemsSupplementBackButton)
    ];
    #endif
}

/**
 *  Return whether two `UINavigationItem` instances are equal
 *
 *  @param navigationItemA The first navigation item
 *  @param navigationItemB The second navigation item
 *
 *  The two instances are considered equal if all properties which have names included in the array
 *  obtained by calling `HUBNavigationItemPropertyNames()` are equal.
 */
static inline BOOL HUBNavigationItemEqualToNavigationItem(UINavigationItem *navigationItemA, UINavigationItem *navigationItemB)
{
    for (NSString * const propertyName in HUBNavigationItemPropertyNames()) {
        if (!HUBPropertyIsEqual(navigationItemA, navigationItemB, propertyName)) {
            return NO;
        }
    }
    
    return YES;
}

/**
 *  Copy the properties from an instance of `UINavigationItem` into another
 *
 *  @param navigationItemA The navigation item to copy values into
 *  @param navigationItemB Any navigation item to copy values from
 *
 *  @return navigationItemA
 *
 *  If `navigationItemB` is nil, all `navigationItemA` properties will be reset to `nil`. To determine
 *  which properties that should be handled, `HUBNavigationItemPropertyNames()` is called.
 */
static inline UINavigationItem *HUBCopyNavigationItemProperties(UINavigationItem *navigationItemA, UINavigationItem * _Nullable navigationItemB)
{
    #if !TARGET_OS_TV
    NSSet<NSString *> * const boolPropertyNames = [NSSet setWithObjects:HUBKeyPath(navigationItemA, hidesBackButton),
                                                                        HUBKeyPath(navigationItemA, leftItemsSupplementBackButton),
                                                                        nil];
    #endif
    for (NSString * const propertyName in HUBNavigationItemPropertyNames()) {
        id const value = [navigationItemB valueForKey:propertyName];

        #if !TARGET_OS_TV
        if (value == nil) {
            if ([boolPropertyNames containsObject:propertyName]) {
                navigationItemA.hidesBackButton = NO;
                continue;
            }
        }
        #endif
        [navigationItemA setValue:value forKey:propertyName];
    }
    
    return navigationItemA;
}

/**
 *  Return a serialized string representation of a serializable object
 *
 *  @param object The object to return a serialized string for
 *
 *  @return A string containing a serialized representation of the object (JSON), or nil if the operation failed
 */
static inline NSString * _Nullable HUBSerializeToString(id<HUBSerializable> object)
{
    NSDictionary * const serialization = [object serialize];
    NSData * const jsonData = [NSJSONSerialization dataWithJSONObject:serialization options:NSJSONWritingPrettyPrinted error:nil];
    
    if (jsonData == nil) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/**
 *  Run a block on the main queue
 *
 *  @param block The block to run
 *
 *  The given block will be run synchronously in case this function is called on the main thread,
 *  or asynchronously if it's not.
 */
static inline void HUBPerformOnMainQueue(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), block);
}

NS_ASSUME_NONNULL_END
