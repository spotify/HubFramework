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


#import "HUBURLSessionMock.h"
#import "HUBURLSessionDataTaskMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBURLSessionMock ()

@property (nonatomic, strong, readonly) NSMutableArray<HUBURLSessionDataTaskMock *> *mutableDataTasks;

@end

@implementation HUBURLSessionMock

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _mutableDataTasks = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Property overrides

- (NSArray<HUBURLSessionDataTaskMock *> *)dataTasks
{
    return [self.mutableDataTasks copy];
}

#pragma mark - NSURLSession

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler
{
    HUBURLSessionDataTaskMock * const task = [[HUBURLSessionDataTaskMock alloc] initWithCompletionHandler:completionHandler];
    [self.mutableDataTasks addObject:task];
    return task;
}

@end

NS_ASSUME_NONNULL_END
