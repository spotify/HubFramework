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


#import "HUBURLProtocolMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBRequestFilter : NSObject

@property (nonatomic, strong, readonly, nullable) NSURL *URL;
@property (nonatomic, copy, readonly, nullable) HUBURLProtocolRequestPredicate predicate;
@property (nonatomic, copy, readonly) HUBURLProtocolRequestHandler requestHandler;

@end

@implementation HUBRequestFilter

- (instancetype)initWithURL:(nullable NSURL *)url
                  predicate:(nullable HUBURLProtocolRequestPredicate)predicate
             requestHandler:(HUBURLProtocolRequestHandler)requestHandler
{
    self = [super init];
    if (self) {
        _URL = url;
        _predicate = predicate;
        _requestHandler = requestHandler;
    }
    return self;
}

- (BOOL)evaluate:(NSURLRequest *)request
{
    if (self.predicate) {
        return self.predicate(request);
    } else if (self.URL) {
        return [self.URL.absoluteString isEqual:request.URL.absoluteString];
    }

    return NO;
}

@end

@implementation HUBURLProtocolMock

static NSArray<HUBRequestFilter *> *urlFilters = nil;

+ (NSArray<HUBRequestFilter *> *)filters
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlFilters = [NSMutableArray array];
    });

    return urlFilters;
}

+ (void)setFilters:(NSArray<HUBRequestFilter *> *)filters
{
    urlFilters = filters;
}

+ (void)addRequestFilter:(HUBRequestFilter *)filter
{
    [self setFilters:[[self filters] arrayByAddingObject:filter]];
}

+ (HUBRequestFilter *)filterMatchingRequest:(NSURLRequest *)request
{
    NSArray<HUBRequestFilter *> *filters = [self filters];
    __block HUBRequestFilter *matchingFilter;

    @synchronized(filters) {
        [filters enumerateObjectsUsingBlock:^(HUBRequestFilter *filter, NSUInteger idx, BOOL *stop) {
            if ([filter evaluate:request]) {
                matchingFilter = filter;
                *stop = YES;
            }
        }];
    }

    return matchingFilter;
}

+ (void)mockRequestsWithURL:(NSURL *)url handler:(HUBURLProtocolRequestHandler)requestHandler
{
    HUBRequestFilter *filter = [[HUBRequestFilter alloc] initWithURL:url predicate:nil requestHandler:requestHandler];
    [self addRequestFilter:filter];
}

+ (void)removeMockForURL:(NSURL *)url
{
    NSArray<HUBRequestFilter *> *filters = [self filters];
    NSMutableArray<HUBRequestFilter *> *mutableFilters = [[self filters] mutableCopy];
    for (HUBRequestFilter *filter in filters) {
        if ([filter.URL.absoluteString isEqual:url.absoluteString]) {
            [mutableFilters removeObject:filter];
        }
    }
    
    [self setFilters:[mutableFilters copy]];
}

+ (void (^)())mockRequestsMatchingPredicate:(HUBURLProtocolRequestPredicate)predicate handler:(HUBURLProtocolRequestHandler)requestHandler
{
    HUBRequestFilter *filter = [[HUBRequestFilter alloc] initWithURL:nil predicate:predicate requestHandler:requestHandler];
    [self addRequestFilter:filter];

    return ^{
        NSMutableArray<HUBRequestFilter *> *mutableFilters = [[self filters] mutableCopy];
        if ([mutableFilters containsObject:filter]) {
            [mutableFilters removeObject:filter];
            [self setFilters:[mutableFilters copy]];
        }
    };
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    HUBRequestFilter *matchingFilter = [self filterMatchingRequest:request];
    return matchingFilter != nil;
}

- (void)startLoading
{
    HUBRequestFilter *filter = [self.class filterMatchingRequest:self.request];

    __block BOOL hasResponse = NO, hasBody = NO;
    void (^completionHandler)() = ^{
        if (hasResponse && hasBody) {
            [self.client URLProtocolDidFinishLoading:self];
        }
    };

    void (^responseHandler)(NSURLResponse *) = ^(NSURLResponse *response) {
        hasResponse = YES;
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        completionHandler();
    };

    void (^dataHandler)(NSData *) = ^(NSData *bodyData) {
        hasBody = YES;
        [self.client URLProtocol:self didLoadData:bodyData];
        completionHandler();
    };

    filter.requestHandler(self.request, responseHandler, dataHandler);
}

- (void)stopLoading
{
    // No-op
}

@end

NS_ASSUME_NONNULL_END
