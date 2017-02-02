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

@protocol HUBActionContext;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol used to define Hub Framework action handlers
 *
 *  An action handler is an object that optionally takes over the handling of an action,
 *  preventing that action from executing as it normally would. This enables you to customize
 *  what will happen for certain actions, including selection and other events.
 *
 *  Each feature can supply each own action handler when it's being setup with `HUBFeatureRegistry`.
 *  A default action handler to be used system-wide can also be supplied when setting up this
 *  application's `HUBManager`.
 */
@protocol HUBActionHandler

/**
 *  Handle an action with a given context
 *
 *  @param context The context of the action to handle
 *
 *  @return A boolean indicating whether the action was handled. If `YES` is returned, the action
 *          will be considered handled, and it won't be executed.
 */
- (BOOL)handleActionWithContext:(id<HUBActionContext>)context;

@end

NS_ASSUME_NONNULL_END
