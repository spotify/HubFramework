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

@protocol HUBComponentFactory;
@protocol HUBComponent;
@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub component registry
 *
 *  A component registry manages a series of registered `HUBComponentFactory` implementations,
 *  that are used to create components for Hub Framework-powered views. To integrate a component
 *  with the framework - implement a `HUBComponentFactory` and register it with the registry.
 *
 *  You don't conform to this protocol yourself, instead the application's `HUBManager` comes
 *  setup with a registry that you can use.
 */
@protocol HUBComponentRegistry <NSObject>

/**
 *  Register a component factory with the Hub Framework
 *
 *  @param componentFactory The factory to register
 *  @param componentNamespace The namespace to register the factory for
 *
 *  The registered factory will be used to create components whenever a component model declared
 *  the given component namespace as part of its `componentIdentifier`.
 */
- (void)registerComponentFactory:(id<HUBComponentFactory>)componentFactory
                    forNamespace:(NSString *)componentNamespace NS_SWIFT_NAME(register(componentFactory:namespace:));

/**
 *  Unregister a component factory from the Hub Framework
 *
 *  @param componentNamespace The namespace of the factory to unregister
 *
 *  After this method has been called, the Hub Framework will remove any factory found for the given namespace,
 *  opening it up to be registered again with another factory. If the given namespace does not exist, this
 *  method does nothing.
 */
- (void)unregisterComponentFactoryForNamespace:(NSString *)componentNamespace;

/**
 *  Create a new component instance for a model
 *
 *  @param model The model to create a component for
 *
 *  @return A newly created component that is ready to use. The component registry will first attempt
 *          to resolve a component factory for the model's `componentNamespace`, and ask it to create
 *          a component. However, if this fails, the registry will use its fallback handler to create
 *          a fallback component for the model's `componentCategory`.
 *
 *  Normally, you don't have to call this method yourself. Instead, the Hub Framework automatically
 *  creates component instances for the models you delcare in a content operation.
 */
- (id<HUBComponent>)createComponentForModel:(id<HUBComponentModel>)model;

@end

NS_ASSUME_NONNULL_END
