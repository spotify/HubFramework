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

@protocol HUBImageLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBImageLoader`
 *
 *  You don't conform to this protocol yourself. Instead, the Hub Framework will assign an internal object
 *  that conforms to this protocol as the delegate of any image loader. You use the methods defined in this
 *  protocol to communicate an image loader's outcomes back to the framework.
 */
@protocol HUBImageLoaderDelegate <NSObject>

/**
 *  Notify the Hub Framework that an image loader finished loading an image
 *
 *  @param imageLoader The image loader that finished loading
 *  @param image The image that was loaded
 *  @param imageURL The URL of the image that was loaded
 *  @param loadedFromCache Whether the image was loaded from cache, or over the network. If loaded from cache,
 *         the Hub Framework won't ask the component that the image is for to apply an animation when displaying
 *         the image.
 *
 *  It's safe to call this method from any thread, as the framework will automatically dispatch to the main
 *  queue in case it's called from a background thread.
 */
- (void)imageLoader:(id<HUBImageLoader>)imageLoader
       didLoadImage:(UIImage *)image
             forURL:(NSURL *)imageURL
          fromCache:(BOOL)loadedFromCache;

/**
 *  Notify the Hub Framework that an image loader failed to load an image because of an error
 *
 *  @param imageLoader The image loader that failed loading
 *  @param imageURL The URL of the image that failed to load
 *  @param error The error that was encountered
 *
 *  It's safe to call this method from any thread, as the framework will automatically dispatch to the main
 *  queue in case it's called from a background thread.
 */
- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error;

@end

/**
 *  Protocol that objects that load images on behalf of the Hub Framework conform to
 *
 *  The Hub Framework uses an image loader to load images for components which models contain image data, when the
 *  component is about to be displayed on the screen. The framework itself does not employ any caching on images, so
 *  it's up to each implementation of this protocol to handle that.
 *
 *  In case you don't supply your own image loader implementation, the default `HUBDefaultImageLoader` is used.
 *
 *  See also `HUBImageLoaderFactory` which is used to create instances conforming to this protocol.
 */
@protocol HUBImageLoader <NSObject>

/// The image loader's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBImageLoaderDelegate> delegate;

/**
 *  Load an image from a certain URL
 *
 *  @param imageURL The URL of the image to load
 *  @param targetSize The target size of the image. It's up to the image loader to either resize the image accordingly,
 *         (if the loaded image has an incorrect size), or ignore this parameter.
 */
- (void)loadImageForURL:(NSURL *)imageURL targetSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
