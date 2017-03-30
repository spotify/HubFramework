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

#import "HUBComponentImageData.h"
#import "HUBComponentType.h"
#import "HUBHeaderMacros.h"

@class HUBComponentWrapper;

NS_ASSUME_NONNULL_BEGIN

/// Contextual object used to track image downloads for components
@interface HUBComponentImageLoadingContext : NSObject

/// The type of the image that this object is for
@property (nonatomic, readonly) HUBComponentImageType imageType;

/// The identifier of the image that this object is for
@property (nonatomic, copy, readonly, nullable) NSString *imageIdentifier;

/// The wrapper for the component that the image is for
@property (nonatomic, weak, readonly) HUBComponentWrapper *wrapper;

/// The creation timestamp
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

/**
 *  Initialize an instance of this class with its required values
 *
 *  @param imageType The type of the image that this object is for
 *  @param imageIdentifier Any identifier for the image that this object is for
 *  @param wrapper The wrapper for the component that the image is for
 *  @param timestamp The creation timestamp
 */
- (instancetype)initWithImageType:(HUBComponentImageType)imageType
                  imageIdentifier:(nullable NSString *)imageIdentifier
                          wrapper:(HUBComponentWrapper *)wrapper
                        timestamp:(NSTimeInterval)timestamp HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
