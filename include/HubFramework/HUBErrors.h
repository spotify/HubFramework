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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark Xcode 7 Compatibility

/// `NSErrorDomain` was introduced in Xcode 8 along with `NS_EXTENSIBLE_STRING_ENUM`. as such we need to fallback to
/// the raw `NSString *` when we compile using Xcode 7.
#ifdef NS_EXTENSIBLE_STRING_ENUM
    #define HUBErrorDomain NSErrorDomain
#else // NS_EXTENSIBLE_STRING_ENUM
    #define HUBErrorDomain NSString *
#endif // NS_EXTENSIBLE_STRING_ENUM


#pragma mark - JSON Serialization Errors

#pragma mark Error Domain
/// Error domain for JSON serialization errors.
FOUNDATION_EXPORT HUBErrorDomain const HUBJSONSerializationErrorDomain;

#pragma mark Error Codes
/**
 *  Error code identifying the type of JSON serialization error that occurred.
 *
 *  - HUBJSONSerializationErrorCodeEmptyData: The given data object was empty or `nil`.
 *  - HUBJSONSerializationErrorCodeInvalidJSON: The data passed as JSON data was invalid.
 */
typedef NS_ENUM(NSInteger, HUBJSONSerializationErrorCode) {
    HUBJSONSerializationErrorCodeEmptyData,
    HUBJSONSerializationErrorCodeInvalidJSON,
};


#pragma mark - Image Loading Errors

#pragma mark Error Domain
/// Error domain for image loading errors.
FOUNDATION_EXPORT HUBErrorDomain const HUBImageLoaderErrorDomain;

#pragma mark Error Codes
/**
 *  Error code identifying the type of image loader error that occurred.
 *
 *  - HUBImageLoaderErrorCodeUnknown: The image data couldn’t be loaded for an unknown reason.
 *  - HUBImageLoaderErrorCodeInvalidData: The data passed as image data was invalid.
 */
typedef NS_ENUM(NSInteger, HUBImageLoaderErrorCode) {
    HUBImageLoaderErrorCodeUnknown,
    HUBImageLoaderErrorCodeInvalidData,
};

NS_ASSUME_NONNULL_END
