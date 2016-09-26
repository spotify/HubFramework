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

#import "HUBFeatureRegistration.h"

#import "HUBFeatureInfoImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBFeatureRegistration

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                                    title:(NSString *)featureTitle
                         viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                      contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
               customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                            actionHandler:(nullable id<HUBActionHandler>)actionHandler
              viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(featureTitle != nil);
    NSParameterAssert(viewURIPredicate != nil);
    NSParameterAssert(contentOperationFactories.count > 0);
    
    self = [super init];
    
    if (self) {
        _featureIdentifier = [featureIdentifier copy];
        _featureTitle = [featureTitle copy];
        _viewURIPredicate = viewURIPredicate;
        _contentOperationFactories = [contentOperationFactories copy];
        _contentReloadPolicy = contentReloadPolicy;
        _customJSONSchemaIdentifier = [customJSONSchemaIdentifier copy];
        _actionHandler = actionHandler;
        _viewControllerScrollHandler = viewControllerScrollHandler;
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
