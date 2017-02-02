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
 *  Protocol defining the public API of an icon object
 *
 *  An icon is not renderable in of itself, but rather acts as a container for icon information, which
 *  can be materialized into an image of any size. Images are resolved using the `HUBIconImageResolver`
 *  passed when setting up `HUBManager`.
 */
@protocol HUBIcon

/// The identifier of the icon. Can be used for custom image resolving.
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 *  Convert the icon into an image of a given size and color
 *
 *  @param size The size of the image to return
 *  @param color The color of the icon image to return
 */
- (nullable UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color NS_SWIFT_NAME(imageWith(size:color:));

@end

NS_ASSUME_NONNULL_END
