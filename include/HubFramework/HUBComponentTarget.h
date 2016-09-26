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

#import "HUBSerializable.h"

@protocol HUBViewModel;
@class HUBIdentifier;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of an object that describes a target of a user interaction
 *  with a Hub Framework component.
 *
 *  You create targets using `HUBComponentTargetBuilder`, available on `HUBComponentModelBuilder`.
 */
@protocol HUBComponentTarget <HUBSerializable>

/**
 *  Any URI that should be opened when the user interacts with the component this target is for
 *
 *  By default, this URI is opened using `[UIApplication openURL:]` when a user interacts with
 *  this target's associated component. This behavior can be overriden by implementing a custom
 *  selection handler (`HUBComponentSelectionHandler`) and sending it when registering a feature
 *  using `HUBFeatureRegistry`.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *URI;

/**
 *  Any initial view model that should be used for the target view
 *
 *  This property can be used to setup several views up-front, either partially or completely.
 *  In case this property is not `nil`, and the target view is a Hub Framework-powered view as
 *  well, the framework will automatically setup that view using this view model. Using this
 *  property might lead to a better user experience, since the user will be able to see a skeleton
 *  version of new views before the their content is loaded, rather than just seing a blank screen.
 */
@property (nonatomic, strong, readonly, nullable) id<HUBViewModel> initialViewModel;

/**
 *  The identifiers of any custom actions that should be performed when the target is executed
 *
 *  When the user interacts with this target's associated component, an `HUBAction` implementation
 *  will be resolved for each identifier in this array. Each action that was found will then be
 *  performed, and if it returned a successful outcome (YES), the target will be considered to be
 *  handled.
 *
 *  You can use actions to implement custom selection behavior without having to modify the framework
 *  itself, by implementing `HUBAction` and registering it through `HUBActionRegistry`. See those
 *  protocols for more information about the Action API.
 */
@property (nonatomic, strong, readonly, nullable) NSArray<HUBIdentifier *> *actionIdentifiers;

/**
 *  Any custom data associated with this target
 *
 *  You can use custom data to set key/value combinations to be used in a custom selection handler
 *  or component to make decisions.
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, NSObject *> *customData;

@end

NS_ASSUME_NONNULL_END
