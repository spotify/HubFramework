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
#import "HUBComponentUIStateManager.h"
#import "HUBIdentifier.h"
#import "HUBComponentModel.h"
#import "HUBComponentRegistry.h"
#import "HUBComponentGestureRecognizer.h"
#import "HUBSingleGestureRecognizerSynchronizer.h"
#import "HUBApplication.h"


NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentReusePool ()

@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;
@property (nonatomic, strong, readonly) HUBComponentUIStateManager *UIStateManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBIdentifier *, NSMutableSet<HUBComponentWrapper *> *> *componentWrappers;
@property (nonatomic, strong, readonly) id<HUBGestureRecognizerSynchronizing> gestureRecognizerSynchronizer;
@property (nonatomic, strong, readonly) id<HUBApplicationProtocol> application;

@end

@implementation HUBComponentReusePool

- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry
                              application:(id<HUBApplicationProtocol>)application
{
    NSParameterAssert(componentRegistry != nil);
    
    self = [super init];
    
    if (self) {
        _componentRegistry = componentRegistry;
        _UIStateManager = [HUBComponentUIStateManager new];
        _componentWrappers = [NSMutableDictionary new];
        _gestureRecognizerSynchronizer = [HUBSingleGestureRecognizerSynchronizer new];
        _application = application;
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
        wrapper.parent = parent;
        [existingWrappers removeObject:wrapper];
        return wrapper;
    }
    
    id<HUBComponent> const component = [self.componentRegistry createComponentForModel:model];

    HUBComponentGestureRecognizer *gestureRecognizer = [[HUBComponentGestureRecognizer alloc]
                                                        initWithSynchronizer:self.gestureRecognizerSynchronizer];

    return [[HUBComponentWrapper alloc] initWithComponent:component
                                                    model:model
                                           UIStateManager:self.UIStateManager
                                                 delegate:delegate
                                        gestureRecognizer:gestureRecognizer
                                                   parent:parent
                                              application:self.application];
}

@end

NS_ASSUME_NONNULL_END
