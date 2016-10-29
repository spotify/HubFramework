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

#import "HUBInputStreamMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBInputStreamMock ()

@property (nonatomic, weak, nullable) id<NSStreamDelegate> streamDelegate;

@end

@implementation HUBInputStreamMock

- (nullable id<NSStreamDelegate>)delegate
{
    return self.streamDelegate;
}

- (void)setDelegate:(nullable id<NSStreamDelegate>)delegate
{
    self.streamDelegate = delegate;
}

- (void)open
{
    // Required to override method
}

- (void)close
{
    // Required to override method
}

- (void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSRunLoopMode)mode
{
    // Required to override method
}

- (BOOL)hasBytesAvailable
{
    return self.data != nil;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength
{
    NSUInteger const dataLength = self.data.length;
    NSParameterAssert(dataLength < maxLength);
    memcpy(buffer, self.data.bytes, dataLength);
    self.data = nil;
    return (NSInteger)dataLength;
}

@end

NS_ASSUME_NONNULL_END
