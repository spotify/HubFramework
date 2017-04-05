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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HUBLiveService;
@protocol HUBContentOperation;


/**
 *  Delegate protocol for `HUBLiveService`
 *
 *  Implement this to recieve view controllers created by the service (using JSON passed from the
 *  `hublive` command line application).
 */
@protocol HUBLiveServiceDelegate

/**
 *  Sent to the delegate whenever the live service created a new content operation
 *
 *  @param liveService The live service in question
 *  @param contentOperation The contentOperation that will feed live data
 *
 *  The live service will reuse any existing content operation if possible. The service does not
 *  retain the content operations it create. An implementor of this protocol should create a
 *  view controller based on the provided content operation app's navigation stack.
 */
- (void)liveService:(id<HUBLiveService>)liveService
didCreateContentOperation:(id<HUBContentOperation>)contentOperation;

@end

/**
 *  Protocol defining the public API for the Hub Framework Live service
 *
 *  The live service enables live editing of Hub Framework-powered view controllers, using the `hublive`
 *  command line application (you can find it in the /live folder of the Hub Framework repo).
 *
 *  To start the service, simply call `startOnPort:` with a port number that you wish to enable the
 *  `hublive` application to connect on (the same port should then be supplied when starting `hublive`).
 *  The service will then call its delegate once it has created a view controller for any JSON data that
 *  was passed from `hublive`.
 *
 *  You don't implement this protocol yourself, instead the Hub Framework contains an implementation of it.
 *  Note though that this implementation is only compiled when the application hosting the framework is
 *  compiled for DEBUG.
 */
@protocol HUBLiveService

/// The service's delegate. See `HUBLiveServiceDelegate` for more information.
@property (nonatomic, weak, nullable) id<HUBLiveServiceDelegate> delegate;

/**
 *  Start the live service on a given port
 *
 *  @param port The port to start the service on
 *
 *  When calling this, the live service will start by creating a Bonjour net service for the given port,
 *  which the `hublive` command application can then connect to to push JSON data for live editing.
 */
- (void)startOnPort:(NSUInteger)port;

/**
 *  Stop the service
 *
 *  The service will immediately stop and tear down its Bonjour net service.
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
