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

#import "HUBConnectivityStateResolverMock.h"

@interface HUBConnectivityStateResolverMock ()

@property (nonatomic, strong, readonly) NSHashTable<id<HUBConnectivityStateResolverObserver>> *observers;

@end

@implementation HUBConnectivityStateResolverMock

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    
    return self;
}

#pragma mark - API

- (void)callObservers
{
    for (id<HUBConnectivityStateResolverObserver> const observer in self.observers) {
        [observer connectivityStateResolverStateDidChange:self];
    }
}

#pragma mark - HUBConnectivityStateResolver

- (HUBConnectivityState)resolveConnectivityState
{
    return self.state;
}

- (void)addObserver:(id<HUBConnectivityStateResolverObserver>)observer
{
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<HUBConnectivityStateResolverObserver>)observer
{
    [self.observers removeObject:observer];
}

@end
