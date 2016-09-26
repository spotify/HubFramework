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

#import "HUBComponentUIStateManager.h"

#import "HUBComponentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentUIStateManager ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id> *statesForComponentModelIdentifiers;

@end

@implementation HUBComponentUIStateManager

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _statesForComponentModelIdentifiers = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (void)saveUIState:(id)state forComponentModel:(id<HUBComponentModel>)componentModel
{
    self.statesForComponentModelIdentifiers[componentModel.identifier] = state;
}

- (nullable id)restoreUIStateForComponentModel:(id<HUBComponentModel>)componentModel
{
    return self.statesForComponentModelIdentifiers[componentModel.identifier];
}

- (void)removeSavedUIStateForComponentModel:(id<HUBComponentModel>)componentModel
{
    self.statesForComponentModelIdentifiers[componentModel.identifier] = nil;
}

@end

NS_ASSUME_NONNULL_END
