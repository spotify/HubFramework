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

#import "HUBLiveContentOperation.h"

#import "HUBViewModelBuilder.h"

#if HUB_DEBUG

NS_ASSUME_NONNULL_BEGIN

@implementation HUBLiveContentOperation

@synthesize delegate = _delegate;

#pragma mark - Initializer

- (instancetype)initWithJSONData:(NSData *)JSONData
{
    NSParameterAssert(JSONData != nil);
    
    self = [super init];
    
    if (self) {
        _JSONData = JSONData;
    }
    
    return self;
}

#pragma mark - Property overrides

- (void)setJSONData:(NSData *)JSONData
{
    _JSONData = JSONData;
    [self.delegate contentOperationRequiresRescheduling:self];
}

#pragma mark - HUBContentOperation

- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    [viewModelBuilder addJSONData:self.JSONData error:nil];
    [self.delegate contentOperationDidFinish:self];
}

@end

NS_ASSUME_NONNULL_END

#endif // DEBUG
