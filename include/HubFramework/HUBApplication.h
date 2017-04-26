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

#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Protocol that exposes UIApplication's properties and methods
@protocol HUBApplicationProtocol <NSObject>

/// The app's key window.
@property(nonatomic, strong, readonly, nullable) UIWindow *keyWindow;

/// The frame rectangle defining the area of the status bar.
@property(nonatomic, assign, readonly) CGRect statusBarFrame;

/// Attempts to open the resource at the specified URL.
- (BOOL)openURL:(NSURL *)url;

@end


/// Class exposing needed properties and methods of UIApplication
@interface HUBApplication: NSObject <HUBApplicationProtocol>

/// Returns singleton instance
+ (instancetype)sharedApplication;

@end

NS_ASSUME_NONNULL_END
