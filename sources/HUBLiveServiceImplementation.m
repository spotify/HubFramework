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

#import "HUBViewControllerFactory.h"
#import "HUBLiveContentOperation.h"

#if HUB_DEBUG

NS_ASSUME_NONNULL_BEGIN

@interface HUBLiveServiceImplementation () <NSNetServiceDelegate, NSStreamDelegate>

@property (nonatomic, strong, readwrite, nullable) NSNetService *netService;
@property (nonatomic, strong, readonly) id<HUBViewControllerFactory> viewControllerFactory;
@property (nonatomic, strong, nullable) NSInputStream *stream;
@property (nonatomic, weak, nullable) UIViewController<HUBViewController> *viewController;
@property (nonatomic, strong, nullable) HUBLiveContentOperation *contentOperation;

@end

@implementation HUBLiveServiceImplementation

@synthesize delegate = _delegate;

#pragma mark - Lifecycle

- (instancetype)initWithViewControllerFactory:(id<HUBViewControllerFactory>)viewControllerFactory
{
    NSParameterAssert(viewControllerFactory != nil);
    
    self = [super init];
    
    if (self) {
        _viewControllerFactory = viewControllerFactory;
    }
    
    return self;
}

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
    
    if (self.viewController != nil && self.contentOperation != nil) {
        self.contentOperation.JSONData = data;
        return;
    }
    
    NSURL * const viewURI = [NSURL URLWithString:@"hubframework:live"];
    
    HUBLiveContentOperation * const contentOperation = [[HUBLiveContentOperation alloc] initWithJSONData:data];
    self.contentOperation = contentOperation;
    
    UIViewController<HUBViewController> * const viewController = [self.viewControllerFactory createViewControllerForViewURI:viewURI
                                                                                                          contentOperations:@[contentOperation]
                                                                                                          featureIdentifier:@"live"
                                                                                                               featureTitle:@"Hub Framework Live"];
    
    self.viewController = viewController;
    [self.delegate liveService:self didCreateViewController:viewController];
}

- (void)closeStream
{
    [self.stream close];
    self.stream = nil;
}

@end

NS_ASSUME_NONNULL_END

#endif // DEBUG
