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

NS_ASSUME_NONNULL_BEGIN

/// Mocked image loader, for use in tests only
@interface HUBImageLoaderMock : NSObject <HUBImageLoader>

/**
 *  Return whether this image loader has been asked to load an image for a certain URL
 */
- (BOOL)hasLoadedImageForURL:(NSURL *)imageURL;

@end

NS_ASSUME_NONNULL_END
