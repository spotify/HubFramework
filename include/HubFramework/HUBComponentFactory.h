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

@protocol HUBComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that create Hub Framework components
 *
 *  You implement a component factory to be able to integrate your component(s) with the framework.
 *  Each factory is registered with `HUBComponentRegistry` for a certain namespace, and will be used
 *  whenever a component model declares that namespace as part of its component identifier.
 */
@protocol HUBComponentFactory <NSObject>

/**
 *  Create a new component matching a name
 *
 *  @param name The name of the component to create
 *
 *  Returning `nil` from this method will cause a fallback component to be used, using the application's
 *  `HUBComponentFallbackHandler` and the component model's `HUBComponentCategory`.
 */
- (nullable id<HUBComponent>)createComponentForName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
