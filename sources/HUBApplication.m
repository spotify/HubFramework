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

#import "HUBApplication.h"

@interface HUBApplication()

@property (nonatomic, strong, readonly) UIApplication *application;

@end

@implementation HUBApplication

+ (instancetype)sharedApplication
{
    static HUBApplication *application = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        application = [HUBApplication new];
    });
    return application;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _application = [UIApplication sharedApplication];
    }
    return self;
}

- (UIWindow *)keyWindow
{
    return self.application.keyWindow;
}

- (CGRect)statusBarFrame
{
    return self.application.statusBarFrame;
}

- (BOOL)openURL:(NSURL *)url
{
    return [self.application openURL:url];
}

@end
