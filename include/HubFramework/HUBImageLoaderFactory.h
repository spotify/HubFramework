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

@protocol HUBImageLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create image loaders for use with the Hub Framework conform to
 *
 *  You conform to this protocol in a custom object and pass that object when setting up `HUBManager`. The
 *  Hub Framework will then use the factory to create an image loader for each view controller that it creates.
 *
 *  In case you don't supply your own image loader factory, the default `HUBDefaultImageLoaderFactory` is used.
 *
 *  See `HUBImageLoader` for more information.
 */
@protocol HUBImageLoaderFactory

/**
 *  Create an image loader
 *
 *  This will be called every time that a view controller is created by the Hub Framework
 */
- (id<HUBImageLoader>)createImageLoader;

@end

NS_ASSUME_NONNULL_END
