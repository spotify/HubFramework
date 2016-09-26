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

@protocol HUBContentOperation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create Hub Framework content operations conform to
 *
 *  You conform to this protocol in a custom object and pass that object when configuring your feature with
 *  the Hub Framework. Multiple content operation factories can be used for a feature, and they can also be
 *  reused in between features.
 *
 *  For more information, see `HUBContentOperation`.
 */
@protocol HUBContentOperationFactory <NSObject>

/**
 *  Create an array of content operations to use for a view with a certain URI
 *
 *  @param viewURI The URI of the view to create content operations for
 *
 *  Content operations are always used in sequence, determined by the order the content operations appear in
 *  the returned array. The array must always contain at least one object.
 */
- (NSArray<id<HUBContentOperation>> *)createContentOperationsForViewURI:(NSURL *)viewURI;

@end

NS_ASSUME_NONNULL_END
