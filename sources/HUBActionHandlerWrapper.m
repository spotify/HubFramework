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

#import "HUBActionHandlerWrapper.h"

#import "HUBActionRegistryImplementation.h"
#import "HUBActionContextImplementation.h"
#import "HUBAction.h"
#import "HUBAsyncAction.h"
#import "HUBAsyncActionWrapper.h"
#import "HUBInitialViewModelRegistry.h"
#import "HUBComponentModel.h"
#import "HUBComponentTarget.h"
#import "HUBViewModelLoaderImplementation.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBActionHandlerWrapper () <HUBAsyncActionWrapperDelegate>

@property (nonatomic, strong, readonly, nullable) id<HUBActionHandler> actionHandler;
@property (nonatomic, strong, readonly) HUBActionRegistryImplementation *actionRegistry;
@property (nonatomic, strong, readonly) HUBInitialViewModelRegistry *initialViewModelRegistry;
@property (nonatomic, strong, readonly) HUBViewModelLoaderImplementation *viewModelLoader;
@property (nonatomic, strong, readonly) NSMutableSet<HUBAsyncActionWrapper *> *ongoingAsyncActions;

@end

@implementation HUBActionHandlerWrapper

#pragma mark - Initializer

- (instancetype)initWithActionHandler:(nullable id<HUBActionHandler>)actionHandler
                       actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
             initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                      viewModelLoader:(HUBViewModelLoaderImplementation *)viewModelLoader
{
    NSParameterAssert(actionRegistry != nil);
    NSParameterAssert(initialViewModelRegistry != nil);
    NSParameterAssert(viewModelLoader != nil);
    
    self = [super init];
    
    if (self) {
        _actionHandler = actionHandler;
        _actionRegistry = actionRegistry;
        _initialViewModelRegistry = initialViewModelRegistry;
        _viewModelLoader = viewModelLoader;
        _ongoingAsyncActions = [NSMutableSet new];
    }
    
    return self;
}

#pragma mark - HUBActionHandler

- (BOOL)handleActionWithContext:(id<HUBActionContext>)context
{
    id<HUBComponentTarget> const target = context.componentModel.target;
    id<HUBAction> action = nil;
    
    if (context.customActionIdentifier == nil) {
        action = self.actionRegistry.selectionAction;
        
        NSURL * const URI = target.URI;
        id<HUBViewModel> const initialViewModel = target.initialViewModel;
        
        if (URI != nil && initialViewModel != nil) {
            [self.initialViewModelRegistry registerInitialViewModel:initialViewModel forViewURI:URI];
        }
    } else {
        HUBIdentifier * const actionIdentifier = context.customActionIdentifier;
        action = [self.actionRegistry createCustomActionForIdentifier:actionIdentifier];
    }
    
    BOOL actionPerformed = NO;
    
    if ([self.actionHandler handleActionWithContext:context]) {
        actionPerformed = YES;
    } else {
        if (HUBConformsToProtocol(action, @protocol(HUBAsyncAction))) {
            id<HUBAsyncAction> const asyncAction = (id<HUBAsyncAction>)action;
            HUBAsyncActionWrapper * const wrapper = [[HUBAsyncActionWrapper alloc] initWithAction:asyncAction context:context];
            wrapper.delegate = self;
            [self.ongoingAsyncActions addObject:wrapper];
        }
        
        actionPerformed = [action performWithContext:context];
    }
    
    if (context.customActionIdentifier == nil && target.URI != nil) {
        NSURL * const targetURI = target.URI;
        [self.initialViewModelRegistry removeInitialViewModelForViewURI:targetURI];
    }
    
    [self.viewModelLoader actionPerformedWithContext:context];
    
    return actionPerformed;
}

#pragma mark - HUBAsyncActionWrapperDelegate

- (void)actionDidFinish:(HUBAsyncActionWrapper *)action
        withContext:(id<HUBActionContext>)context
        chainToActionWithIdentifier:(nullable HUBIdentifier *)nextActionIdentifier
        customData:(nullable NSDictionary<NSString *, id> *)nextActionCustomData
{
    [self.ongoingAsyncActions removeObject:action];
    
    if (nextActionIdentifier != nil) {
        HUBIdentifier * const chainedActionIdentifier = nextActionIdentifier;
        HUBActionContextImplementation * const chainedActionContext = [[HUBActionContextImplementation alloc] initWithTrigger:context.trigger
                                                                                                       customActionIdentifier:chainedActionIdentifier
                                                                                                                   customData:nextActionCustomData
                                                                                                                  featureInfo:context.featureInfo
                                                                                                                      viewURI:context.viewURI
                                                                                                                    viewModel:context.viewModel
                                                                                                               componentModel:context.componentModel
                                                                                                               viewController:context.viewController];
        
        [self handleActionWithContext:chainedActionContext];
    }
}

@end

NS_ASSUME_NONNULL_END
