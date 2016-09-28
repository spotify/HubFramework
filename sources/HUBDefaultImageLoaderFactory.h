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


#import "HUBImageLoaderFactory.h"

/**
 *  Default image loader factory used for applications that do not define their own
 *
 *  This image loader factory is used if `nil` is passed as `imageLoaderFactory` when setting
 *  up the application's `HUBManager`. It produces instances of `HUBDefaultImageLoader`, so see
 *  the documentation for that class for more information.
 *
 *  In case you need more powerful image loader features you might want to either implement
 *  your own factory using `HUBImageLoaderFactory`, or adding a wrapper for that protocol around
 *  an image loading library.
 */
@interface HUBDefaultImageLoaderFactory : NSObject <HUBImageLoaderFactory>

@end
