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

#import "HUBJSONParsingOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONParsingOperation ()

@property (nonatomic, copy, readonly) NSArray<NSObject *> * _Nullable (^block)(NSObject *);

@end

@implementation HUBJSONParsingOperation

- (instancetype)initWithBlock:(NSArray<NSObject *> * _Nullable (^)(NSObject *))block
{
    NSParameterAssert(block != nil);
    
    self = [super init];
    
    if (self) {
        _block = [block copy];
    }
    
    return self;
}

- (nullable NSArray<NSObject *> *)parsedValuesForInput:(NSObject *)input
{
    NSParameterAssert(input != nil);
    return self.block(input);
}

@end

NS_ASSUME_NONNULL_END
