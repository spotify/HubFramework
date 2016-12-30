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

#import "HUBAction.h"

@protocol HUBAsyncAction;
@class HUBIdentifier;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol used by `HUBAsyncAction` types to notify the Hub Framework when they finish
@protocol HUBAsyncActionDelegate

/**
 *  Notify the Hub Framework that an asynchronous action finished
 *
 *  @param action The action that was finished
 *  @param nextActionIdentifier The identifier of any action to chain this action to. Any action
 *         matching this identifier will immediately be invoked, optionally with the given custom data.
 *  @param nextActionCustomData Any custom data to pass to the next action that this one chains to
 *
 *  Call this method whenever an asynchronous action finished doing its work, to enable the Hub Framework
 *  to release it from memory. You can also (optionally) at this point chain the action that was finished
 *  to another, by supplying an action identifier and any custom data. This enables you to create chains
 *  of logic from actions.
 */
- (void)actionDidFinish:(id<HUBAsyncAction>)action
        chainToActionWithIdentifier:(nullable HUBIdentifier *)nextActionIdentifier
        customData:(nullable NSDictionary<NSString *, id> *)nextActionCustomData NS_SWIFT_NAME(actionDidFinish(_:chainToActionWithIdentifier:customData:));

@end

/**
 *  Extended action protocol used to define actions that are asynchronous
 *
 *  Asynchronous actions enable you to perform work even after the main `performWithContext:`
 *  method has returned. Once you're done performing an async action, call its delegate. The
 *  Hub Framework will automatically retain any performed asynchronous actions until they have
 *  been completed.
 */
@protocol HUBAsyncAction <HUBAction>

/**
 *  The action's delegate
 *
 *  The Hub Framework will assign an object to this property, so just \@synthesize it, and use
 *  the delegate to notify the framework when your action has completed and can safely be released.
 */
@property (nonatomic, weak, nullable) id<HUBAsyncActionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
