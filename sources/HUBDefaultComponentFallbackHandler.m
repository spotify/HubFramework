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

#import "HUBDefaultComponentFallbackHandler.h"
#import "HUBDefaults.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDefaultComponentFallbackHandler ()

@property (nonatomic, copy, readonly) id<HUBComponent>(^fallbackBlock)(HUBComponentCategory);

@end

@implementation HUBDefaultComponentFallbackHandler

@synthesize defaultComponentNamespace = _defaultComponentNamespace;
@synthesize defaultComponentName = _defaultComponentName;

- (instancetype)initWithFallbackBlock:(id<HUBComponent>(^)(HUBComponentCategory))fallbackBlock
{
    NSParameterAssert(fallbackBlock != nil);
    
    self = [super init];
    
    if (self) {
        _defaultComponentNamespace = HUBDefaultComponentNamespace;
        _defaultComponentName = @"row";
        _fallbackBlock = [fallbackBlock copy];
    }
    
    return self;
}

#pragma mark - HUBComponentFallbackHandler

- (HUBComponentCategory)defaultComponentCategory
{
    return HUBComponentCategoryRow;
}

- (id<HUBComponent>)createFallbackComponentForCategory:(HUBComponentCategory)componentCategory
{
    return self.fallbackBlock(componentCategory);
}

@end

NS_ASSUME_NONNULL_END
