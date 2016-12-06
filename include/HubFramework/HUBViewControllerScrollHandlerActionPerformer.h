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

#import "HUBViewControllerScrollHandler.h"

@protocol HUBActionPerformer;

/**
 *  Extended scroll handler protocol that adds the ability to perform actions
 *
 *  Use this protocol whenever you want your scroll handler to be able to perform
 *  actions. Actions can be used to perform small, atomic tasks and provide a lightweight way
 *  to extend the Hub Framework with additional functionality.
 *
 *  For more information about actions, see `HUBAction`, as well as the "Action programming
 *  guide" available at https://spotify.github.io/HubFramework/action-programming-guide.html.
 *
 *  For more information about scroll handler, see `HUBViewControllerScrollHandler`.
 */
@protocol HUBViewControllerScrollHandlerActionPerformer <HUBViewControllerScrollHandler>

/**
 *  An object that can be used to perform actions on behalf of this scroll handler
 *
 *  Don't assign any custom objects to this property. Instead, just \@sythensize it, so that
 *  the Hub Framework can assign an internal object to this property, to enable you to perform
 *  actions from the scroll handler.
 */
@property (nonatomic, weak, nullable) id<HUBActionPerformer> actionPerformer;

@end

