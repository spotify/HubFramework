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

@protocol HUBActionFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub Framework action registry
 *
 *  An action registry manages a series of registered `HUBActionFactory` implementations, that are
 *  used to create actions for handling events occuring in Hub Framework-powered views. To integrate
 *  actions with the framework - implement a `HUBActionFactory` and register it with the registry.
 *
 *  You don't conform to this protocol yourself, instead the application's `HUBManager` comes setup
 *  with a registry that you can use.
 */
@protocol HUBActionRegistry <NSObject>

/**
 *  Register an action factory with the Hub Framework
 *
 *  @param actionFactory The factory to register
 *  @param actionNamespace The namespace to register the factory for
 *
 *  The registered factory will be used to create actions whenever an event's action identifier
 *  contained the namespace that the factory was registered for.
 */
- (void)registerActionFactory:(id<HUBActionFactory>)actionFactory
                 forNamespace:(NSString *)actionNamespace;

/**
 *  Unregister an action factory from the Hub Framework
 *
 *  @param actionNamespace The namespace of the factory to unregister
 *
 *  After this method has been called, the Hub Framework will remove any factory found for the given
 *  namespace, opening it up to be registered again with another factory. If the given namespace does
 *  not exist, this method does nothing.
 */
- (void)unregisterActionFactoryForNamespace:(NSString *)actionNamespace;

@end

NS_ASSUME_NONNULL_END
