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
#import <CoreGraphics/CoreGraphics.h>

#import "HUBHeaderMacros.h"

@protocol HUBImageLoader;

@class HUBComponentWrapper;

NS_ASSUME_NONNULL_BEGIN

/**
 A class that wraps a HUBImageLoader and handles the image loading logic for component wrappers.
 */
@interface HUBComponentWrapperImageLoader : NSObject

/**
 Designated initializer.

 @param imageLoader The image loader.
 */
- (instancetype)initWithImageLoader:(id<HUBImageLoader>)imageLoader HUB_DESIGNATED_INITIALIZER;


/**
 Loads all images (main, background and custom) in the component wrapper's model.

 @param componentWrapper The component wrapper.
 @param containerViewSize The container view's size.
 */
- (void)loadImagesForComponentWrapper:(HUBComponentWrapper *)componentWrapper
                    containerViewSize:(CGSize)containerViewSize;

@end

NS_ASSUME_NONNULL_END
