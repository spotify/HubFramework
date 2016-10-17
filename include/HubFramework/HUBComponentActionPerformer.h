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

#import "HUBComponent.h"

@protocol HUBActionPerformer;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended Hub component protocol that adds the ability to perform actions
 *
 *  Use this protocol if you want your component to be able to perform actions based on custom user interactions
 *  or other events. By default The Hub Framework performs any actions associated with a component model's target
 *  when the component is selected by the user, but this protocol makes it possible to perform any other action
 *  whenever the component wants. For example, you might want to trigger an action whenever the user swipes the
 *  component, or something similar.
 *
 *  See `HUBComponent` and `HUBAction` for more information.
 */
@protocol HUBComponentActionPerformer <HUBComponent>

/**
 *  An object that can be used to perform actions on behalf of this component
 *
 *  Don't assign any custom objects to this property. Instead, just \@sythensize it, so that the Hub Framework can
 *  assign an internal object to this property, to enable you to perform actions from the component.
 */
@property (nonatomic, weak, nullable) id<HUBActionPerformer> actionPerformer;

@end

NS_ASSUME_NONNULL_END
