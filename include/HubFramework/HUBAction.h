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

@protocol HUBActionContext;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol used to define Hub Framework actions
 *
 *  Actions are independant pieces of code that can be executed in response to events, such as selection,
 *  other user interface events, timers, etc. They can be used to implement application-wide extensions
 *  to the Hub Framework and handle tasks like model mutations, user interface updates, etc. Actions are
 *  either performed automatically by the Hub Framework when a component was selected, or by a component
 *  conforming to the `HUBComponentActionPerformer` protocol.
 *
 *  Actions are created by an implementation of `HUBActionFactory`, which are registered for a certain
 *  namespace with `HUBActionRegistry`.
 */
@protocol HUBAction <NSObject>

/**
 *  Perform the action in a certain context
 *
 *  @param context The context to perform the action in
 *
 *  @return A boolean indicating whether the action was performed or not. When an action indicates success,
 *          it will stop any subsequent actions from being performed for the same event.
 */
- (BOOL)performWithContext:(id<HUBActionContext>)context;

@end

NS_ASSUME_NONNULL_END
