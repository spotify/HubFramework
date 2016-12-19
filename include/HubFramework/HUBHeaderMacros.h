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

/// Macro that marks an initializer as designated, and also makes the default Foundation initializers unavailable
#define HUB_DESIGNATED_INITIALIZER NS_DESIGNATED_INITIALIZER; \
    /** Unavailable. Use the designated initializer instead */ \
    + (instancetype)new NS_UNAVAILABLE; \
    /** Unavailable. Use the designated initializer instead */ \
    - (instancetype)init NS_UNAVAILABLE; \
    /** Unavailable. Use the designated initializer instead */ \
    - (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/// This macro was introduced in Xcode 8, so adding this here for now (if not defined) to support Xcode 7 as well.
#ifdef NS_EXTENSIBLE_STRING_ENUM
    #define HUBS_EXTENSIBLE_STRING_ENUM NS_EXTENSIBLE_STRING_ENUM
#else // NS_EXTENSIBLE_STRING_ENUM
    #define HUBS_EXTENSIBLE_STRING_ENUM
#endif // NS_EXTENSIBLE_STRING_ENUM


/// Define an explicit `HUB_DEBUG` macro for conditionally compiling debug code
#ifdef DEBUG
    #define HUB_DEBUG DEBUG
#else
    #define HUB_DEBUG 0
#endif
