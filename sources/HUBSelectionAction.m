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

#import "HUBSelectionAction.h"

#import "HUBActionContext.h"
#import "HUBComponentModel.h"
#import "HUBComponentTarget.h"

@interface HUBSelectionAction()

@property (nonatomic, strong, readonly) UIApplication *application;

@end

@implementation HUBSelectionAction

- (instancetype)initWithApplication:(UIApplication *)application
{
    NSParameterAssert(application != nil);

    self = [super init];
    if (self) {
        _application = application;
    }
    return self;
}

- (BOOL)performWithContext:(id<HUBActionContext>)context
{
    NSURL * const targetURI = context.componentModel.target.URI;
    
    if (targetURI == nil) {
        return NO;
    }
    
    return [self.application openURL:targetURI];
}

@end
