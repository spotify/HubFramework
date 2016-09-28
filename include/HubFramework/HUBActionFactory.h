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

@protocol HUBAction;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol used to define factories that create Hub Framework actions
 *
 *  You implement a factory to integrate actions with the framework. Each factory is registered
 *  for a certain namespace with `HUBActionRegistry`, and will be invoked when an action identifier
 *  with the matching namespace was encountered as part of the handling of an event.
 */
@protocol HUBActionFactory <NSObject>

/**
 *  Create an action for a certain name
 *
 *  @param name The name of the action to create
 *
 *  Return nil if the name is unrecognized by this factory
 */
- (nullable id<HUBAction>)createActionForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
