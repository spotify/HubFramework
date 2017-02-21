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

NS_ASSUME_NONNULL_BEGIN

/**
 *  `HUBGestureRecognizerSynchronizing` object is used to keep track of active `HUBComponentGestureRecognizers` so they
 *  can be performed one at a time. It is passed to `HUBComponentGestureRecognizers` when initialized.
 */
@protocol HUBGestureRecognizerSynchronizing

/**
 *  If this property is set to `YES`, a `HUBComponentGestureRecognizers` that is about to begin handling touch events
 *  should fail.
 *
 *  If this property is set to `NO`, a `HUBComponentGestureRecognizers` that is about to begin handling touch events
 *  should set this flag to `YES` and proceed with handling touch events.
 */
@property (nonatomic, assign, getter=isLocked) BOOL locked;

@end

NS_ASSUME_NONNULL_END
