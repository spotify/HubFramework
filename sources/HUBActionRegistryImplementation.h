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

#import "HUBActionRegistry.h"
#import "HUBHeaderMacros.h"
#import "HUBApplication.h"

@protocol HUBAction;
@class HUBIdentifier;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBActionRegistry` API
@interface HUBActionRegistryImplementation : NSObject <HUBActionRegistry>


/**
 *  Create an instance of this class with the default selection action
 *
 *  To be able to specify which selection action to use (useful for tests), use this class'
 *  designated initializer instead of this class constructor.
 */
+ (instancetype)registryWithDefaultSelectionActionAndApplication:(id<HUBApplication>)application;

/**
 *  Initialize an instance of this class with a selection action
 *
 *  @param selectionAction The action to be performed whenever a selection event occurs
 */
- (instancetype)initWithSelectionAction:(id<HUBAction>)selectionAction HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
