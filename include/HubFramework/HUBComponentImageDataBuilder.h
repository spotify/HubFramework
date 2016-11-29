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

#import "HUBJSONCompatibleBuilder.h"
#import "HUBComponentImageData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API for a builder that builds image data objects
 *
 *  This builder acts like a mutable model counterpart for `HUBComponentImageData`, with the key
 *  difference that they are not related by inheritance.
 *
 *  All properties are briefly documented as part of this protocol, but for more extensive
 *  documentation and use case examples, see the full documentation in the `HUBComponentImageData`
 *  protocol definition.
 *
 *  In order to successfully build an image data object (and not return nil), the builder must
 *  have either have a non-nil `URL`, `placeholderIconIdentifier` or `localImage` property.
 */
@protocol HUBComponentImageDataBuilder <HUBJSONCompatibleBuilder>

/// Any HTTP URL of a remote image that should be downloaded and then rendered
@property (nonatomic, copy, nullable) NSURL *URL;

/**
 *  Any identifier of a placeholder icon that should be used while a remote image is downloaded
 *
 *  The image for the icon will be resolved using the application's `HUBIconImageResolver`.
 */
@property (nonatomic, copy, nullable) NSString *placeholderIconIdentifier;

/// Any local image that should be used, either as a placeholder or a permanent image
@property (nonatomic, strong, nullable) UIImage *localImage;

/// Any custom data that should be associated with the image data object
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *customData;

@end

NS_ASSUME_NONNULL_END
