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


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A block type used to provide a mocked request with an @c NSURLResponse.
typedef void(^HUBURLProtocolResponseHandler)(NSURLResponse *response);

/// A block type used to provide a mocked request with an @c NSData.
typedef void(^HUBURLProtocolDataHandler)(NSData *data);

/// A block type used for catching outgoing @c NSURLRequests.
typedef void(^HUBURLProtocolRequestHandler)(NSURLRequest *request, HUBURLProtocolResponseHandler responseHandler, HUBURLProtocolDataHandler dataHandler);

/// A block type used for catching outgoing @c NSURLRequests.
typedef BOOL(^HUBURLProtocolRequestPredicate)(NSURLRequest *request);

/**
 * The @c HUBURLCacheMock class provides an easy interface to mock cached responses of HTTP requests. 
 */
@interface HUBURLProtocolMock : NSURLProtocol

/**
 * Mocks any outgoing requests with the given URL, calling the request handler. The request handler is expected
 * to call both the response handler as well as the data handler.
 * @param url The URL to mock.
 * @param requestHandler The request handler that will be called once a request with a matching URL goes out.
 */
+ (void)mockRequestsWithURL:(NSURL *)url handler:(HUBURLProtocolRequestHandler)requestHandler;

/**
 * Removes a previously mocked URL handler.
 * @param url The URL of the mock to remove.
 */
+ (void)removeMockForURL:(NSURL *)url;

/**
 * Mocks any outgoing requests that matches the provided predicate, calling the request handler. The request handler 
 * is expected to call both the response handler as well as the data handler.
 * @param predicate The predicate that determines if a request should be handled by the mock or not.
 * @param requestHandler The request handler that will be called once a request with a matching URL goes out.
 */
+ (void (^)(void))mockRequestsMatchingPredicate:(HUBURLProtocolRequestPredicate)predicate handler:(HUBURLProtocolRequestHandler)requestHandler;

@end

NS_ASSUME_NONNULL_END
