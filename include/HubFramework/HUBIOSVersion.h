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

#ifndef NSFoundationVersionNumber_iOS_10_x_Max
#define NSFoundationVersionNumber_iOS_10_x_Max 1399
#endif

/**
 Is the app running under iOS 11.0 or newer?
 */
NS_INLINE BOOL HUBIsIOS11OrNewer(void)
{
    return NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_10_x_Max;
}

#ifdef __IPHONE_11_0

/**
 Execute `block` if the user is running iOS 11 or newer.
 */
NS_INLINE void HUBIfIOS11OrNewer(dispatch_block_t _Nonnull block)
{
    if (HUBIsIOS11OrNewer()) {
        block();
    }
}

#else

/**
 This will not compile as the iOS 11 SDK is not available with the current version of Xcode.
 */
#define HUBIfIOS11OrNewer(block)

#endif
