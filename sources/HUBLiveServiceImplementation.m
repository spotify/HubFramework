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

#import "HUBLiveServiceImplementation.h"

#import "HUBLiveContentOperation.h"

#if HUB_DEBUG

NS_ASSUME_NONNULL_BEGIN

@interface HUBLiveServiceImplementation () <NSNetServiceDelegate, NSStreamDelegate>

@property (nonatomic, strong, readwrite, nullable) NSNetService *netService;
@property (nonatomic, strong, readonly) id<HUBViewControllerFactory> viewControllerFactory;
@property (nonatomic, strong, nullable) NSInputStream *stream;
@property (nonatomic, weak, nullable) HUBLiveContentOperation *contentOperation;

@end

@implementation HUBLiveServiceImplementation

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (void)dealloc
{
    [self stop];
}

#pragma mark - HUBLiveService

- (void)startOnPort:(NSUInteger)port
{
    [self.netService stop];
    
    self.netService = [[NSNetService alloc] initWithDomain:@""
                                                      type:@"_spotify_hub_live._tcp."
                                                      name:@"Hub Framework Live Service"
                                                      port:(int)port];
    
    self.netService.delegate = self;
    [self.netService publishWithOptions:NSNetServiceListenForConnections];
}

- (void)stop
{
    [self.netService stop];
    self.netService = nil;
    
    [self closeStream];
}

#pragma mark - NSNetServiceDelegate

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    self.stream = inputStream;
    self.stream.delegate = self;
    [self.stream open];
    [self.stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) { 
        case NSStreamEventHasBytesAvailable:
            [self handleBytesAvailableForStream:(NSInputStream *)stream];
            break;
        case NSStreamEventErrorOccurred:
            [self closeStream];
            break;
        case NSStreamEventNone:
        case NSStreamEventOpenCompleted:
        case NSStreamEventEndEncountered:
        case NSStreamEventHasSpaceAvailable:
            break;
    }
}

#pragma mark - Private utilities

- (void)handleBytesAvailableForStream:(NSInputStream *)stream
{
    NSMutableData * const mutableData = [NSMutableData new];
    NSUInteger const bufferSize = 1024;
    
    while (stream.hasBytesAvailable) {
        uint8_t buffer[bufferSize];
        NSInteger const bytesRead = [stream read:buffer maxLength:bufferSize];
        [mutableData appendBytes:buffer length:(NSUInteger)bytesRead];
    }
    
    NSData * const data = [mutableData copy];

    HUBLiveContentOperation *existingContentOperation = self.contentOperation;
    if (existingContentOperation != nil) {
        existingContentOperation.JSONData = data;
        return;
    }

    HUBLiveContentOperation * const contentOperation = [[HUBLiveContentOperation alloc] initWithJSONData:data];
    self.contentOperation = contentOperation;

    [self.delegate liveService:self didCreateContentOperation:contentOperation];
}

- (void)closeStream
{
    [self.stream close];
    self.stream = nil;
}

@end

NS_ASSUME_NONNULL_END

#endif // DEBUG
