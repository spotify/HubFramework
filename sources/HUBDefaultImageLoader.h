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


#import "HUBImageLoader.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Default image loader used for applications that do not define their own
 *
 *  This image loader is used if `nil` is passed as `imageLoaderFactory` when setting up the
 *  application's `HUBManager`. The implementation is quite simple and uses NSURLSession to
 *  download images over HTTP. It also provides a resize feature, that automatically resizes
 *  images if the requested `targetSize` doesn't match the size of a downloaded image.
 *
 *  To adjust this image loader's caching behavior, refer to `NSURLCache`.
 *
 *  In case you need more powerful image loader features you might want to either implement
 *  your own using `HUBImageLoader`, or adding a wrapper for that protocol around an image
 *  loading library.
 */
@interface HUBDefaultImageLoader : NSObject <HUBImageLoader>

/**
 *  Initialize an instance of this class with an URL session to use
 *
 *  @param session The URL session to use. Typically the application's shared session.
 */
- (instancetype)initWithSession:(NSURLSession *)session HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
