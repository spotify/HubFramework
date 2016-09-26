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

#import <UIKIt/UIKit.h>

/**
 *  Protocol defining the public API of an object that can generate showcase snapshots
 *
 *  Use this API to generate snapshot images of components, that can be used in showcases
 *  or tooling associated with the Hub Framework. Normally, you don't interact with it
 *  in production code.
 *
 *  You don't conform to this protocol yourself, instead request an instance conforming
 *  to it from the application's `HUBComponentShowcaseManager`.
 */
@protocol HUBComponentShowcaseSnapshotGenerator <NSObject>

/**
 *  Generate a snapshot of the component that this object represents
 *
 *  @param containerViewSize The size of the container view that the component should
 *         be simulated to be added in. This will be taken into account when calculating
 *         the size of the component's view and thus the snapshot.
 */
- (UIImage *)generateShowcaseSnapshotForContainerViewSize:(CGSize)containerViewSize;

@end
