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

#import "HUBActionHandlerMock.h"

#import "HUBActionContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBActionHandlerMock ()

@property (nonatomic, strong, readonly) NSMutableArray<id<HUBActionContext>> *mutableContexts;

@end

@implementation HUBActionHandlerMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableContexts = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSArray<id<HUBActionContext>> *)contexts
{
    return [self.mutableContexts copy];
}

#pragma mark - HUBActionHandler

- (BOOL)handleActionWithContext:(id<HUBActionContext>)context
{
    if (self.block == nil) {
        return NO;
    }
    
    [self.mutableContexts addObject:context];
    
    return self.block(context);
}

@end

NS_ASSUME_NONNULL_END
