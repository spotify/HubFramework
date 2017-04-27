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

#import "HUBActionRegistryImplementation.h"

#import "HUBActionFactory.h"
#import "HUBIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBActionRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBActionFactory>> *actionFactories;

@end

@implementation HUBActionRegistryImplementation
@synthesize selectionAction = _selectionAction;

#pragma mark - Initializers

- (instancetype)initWithSelectionAction:(id<HUBAction>)selectionAction
{
    NSParameterAssert(selectionAction != nil);
    
    self = [super init];
    
    if (self) {
        _selectionAction = selectionAction;
        _actionFactories = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (nullable id<HUBAction>)createCustomActionForIdentifier:(HUBIdentifier *)identifier
{
    id<HUBActionFactory> const factory = self.actionFactories[identifier.namespacePart];
    return [factory createActionForName:identifier.namePart];
}

#pragma mark - HUBActionRegistry

- (void)registerActionFactory:(id<HUBActionFactory>)actionFactory forNamespace:(NSString *)actionNamespace
{
    if (self.actionFactories[actionNamespace] != nil) {
        NSAssert(NO,
                 @"Attempted to register an action factory for a namespace that has already been registered: %@",
                 actionNamespace);
    }
    
    self.actionFactories[actionNamespace] = actionFactory;
}

- (void)unregisterActionFactoryForNamespace:(NSString *)actionNamespace
{
    self.actionFactories[actionNamespace] = nil;
}

@end

NS_ASSUME_NONNULL_END
