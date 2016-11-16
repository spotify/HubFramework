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

#import "HUBComponentReusePool.h"

#import "HUBComponentWrapper.h"
#import "HUBIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBComponentRegistry.h"
#import "HUBComponentGestureRecognizer.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentReusePool ()

@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBIdentifier *, NSMutableSet<HUBComponentWrapper *> *> *componentWrappers;

@end

@implementation HUBComponentReusePool

- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry
                           UIStateManager:(HUBComponentUIStateManager *)UIStateManager
{
    NSParameterAssert(componentRegistry != nil);
    NSParameterAssert(UIStateManager != nil);
    
    self = [super init];
    
    if (self) {
        _componentRegistry = componentRegistry;
        _UIStateManager = UIStateManager;
        _componentWrappers = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)addComponentWrappper:(HUBComponentWrapper *)componentWrapper
{
    HUBIdentifier * const componentIdentifier = componentWrapper.model.componentIdentifier;
    NSMutableSet * const existingWrappers = self.componentWrappers[componentIdentifier];
    
    if (existingWrappers != nil) {
        [existingWrappers addObject:componentWrapper];
    } else {
        self.componentWrappers[componentIdentifier] = [NSMutableSet setWithObject:componentWrapper];
    }
}

- (HUBComponentWrapper *)componentWrapperForModel:(id<HUBComponentModel>)model
                                         delegate:(id<HUBComponentWrapperDelegate>)delegate
                                           parent:(nullable HUBComponentWrapper *)parent
{
    NSMutableSet * const existingWrappers = self.componentWrappers[model.componentIdentifier];
    
    if (existingWrappers.count > 0) {
        HUBComponentWrapper * const wrapper = [existingWrappers anyObject];
        wrapper.delegate = delegate;
        [existingWrappers removeObject:wrapper];
        return wrapper;
    }
    
    id<HUBComponent> const component = [self.componentRegistry createComponentForModel:model];
    
    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:delegate
                                        gestureRecognizer:[HUBComponentGestureRecognizer new]
                                                   parent:parent];
}

@end

NS_ASSUME_NONNULL_END
