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

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that can resolve images from icon identifiers
 *
 *  You conform to this protocol in a custom object and supply it when setting up your application's
 *  `HUBManager`. The Hub Framework uses this object whenever an image needs to be resolved from a
 *  `HUBIcon` instance.
 */
@protocol HUBIconImageResolver <NSObject>

/**
 *  Resolve an image for component icon
 *
 *  @param iconIdentifier The identifier of the icon
 *  @param size The size of the image to return
 *  @param color The color of the icon image to return
 */
- (nullable UIImage *)imageForComponentIconWithIdentifier:(NSString *)iconIdentifier
                                                     size:(CGSize)size
                                                    color:(UIColor *)color;

/**
 *  Resolve an image for a placeholder icon
 *
 *  @param iconIdentifier The identifier of the icon
 *  @param size The size of the image to return
 *  @param color The color of the icon image to return
 */
- (nullable UIImage *)imageForPlaceholderIconWithIdentifier:(NSString *)iconIdentifier
                                                       size:(CGSize)size
                                                      color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
