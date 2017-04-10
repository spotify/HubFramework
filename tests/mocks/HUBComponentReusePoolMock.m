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

#import "HUBComponentReusePoolMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentReusePoolMock ()

@property (nonatomic, strong, readonly) NSHashTable *mutableComponentsInUse;

@end

@implementation HUBComponentReusePoolMock

#pragma mark - Initializer

- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry application:(id<HUBApplicationProtocol>)application
{
    self = [super initWithComponentRegistry:componentRegistry application:application];
    
    if (self) {
        _mutableComponentsInUse = [NSHashTable weakObjectsHashTable];
    }
    
    return self;
}

#pragma mark - HUBComponentReusePool

- (HUBComponentWrapper *)componentWrapperForModel:(id<HUBComponentModel>)model
                                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                                           parent:(nullable HUBComponentWrapper *)parent
{
    HUBComponentWrapper * const componentWrapper = [super componentWrapperForModel:model
                                                                          delegate:delegate
                                                                            parent:parent];
    
    [self.mutableComponentsInUse addObject:componentWrapper];
    return componentWrapper;
}

#pragma mark - Property overrides

- (NSArray<HUBComponentWrapper *> *)componentsInUse
{
    return self.mutableComponentsInUse.allObjects;
}

@end

NS_ASSUME_NONNULL_END
