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

#import "HUBAsyncActionWrapper.h"
#import "HUBAsyncAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBAsyncActionWrapper () <HUBAsyncActionDelegate>

@property (nonatomic, strong, readonly) id<HUBAsyncAction> action;
@property (nonatomic, strong, readonly) id<HUBActionContext> context;

@end

@implementation HUBAsyncActionWrapper

#pragma mark - Initializer

- (instancetype)initWithAction:(id<HUBAsyncAction>)action context:(id<HUBActionContext>)context
{
    NSParameterAssert(action != nil);
    NSParameterAssert(context != nil);
    
    self = [super init];
    
    if (self) {
        _action = action;
        _context = context;
        
        _action.delegate = self;
    }
    
    return self;
}

#pragma mark - API

- (BOOL)perform
{
    return [self.action performWithContext:self.context];
}

#pragma mark - HUBAsyncActionDelegate

- (void)actionDidFinish:(id<HUBAsyncAction>)action
        chainToActionWithIdentifier:(nullable HUBIdentifier *)nextActionIdentifier
        customData:(nullable NSDictionary<NSString *, id> *)nextActionCustomData
{
    [self.delegate actionDidFinish:self
                       withContext:self.context
       chainToActionWithIdentifier:nextActionIdentifier
                        customData:nextActionCustomData];
}

@end

NS_ASSUME_NONNULL_END
