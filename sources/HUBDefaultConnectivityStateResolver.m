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

#import "HUBDefaultConnectivityStateResolver.h"

#import "HUBUtilities.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

void HUBReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info);

@interface HUBDefaultConnectivityStateResolver ()

@property (nonatomic, strong, readonly) NSHashTable<id<HUBConnectivityStateResolverObserver>> *observers;
@property (nonatomic, assign, readonly) SCNetworkReachabilityRef reachability;
@property (nonatomic, retain, readonly) dispatch_queue_t dispatchQueue;
@property (nonatomic, strong, nullable) NSNumber *connectivityState;

@end

@implementation HUBDefaultConnectivityStateResolver

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _observers = [NSHashTable weakObjectsHashTable];
        
        struct sockaddr_in zeroAddress;
        bzero(&zeroAddress, sizeof(zeroAddress));
        zeroAddress.sin_len = sizeof(zeroAddress);
        zeroAddress.sin_family = AF_INET;
        
        SCNetworkReachabilityRef const reachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
        NSAssert(reachability != nil, @"Could not create reachability object");
        _reachability = reachability;
        
        _dispatchQueue = dispatch_queue_create("HUBDefaultConnectivityStateResolver", NULL);
        
        [self startObservingReachability];
    }
    
    return self;
}

- (void)dealloc
{
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachability, [[NSRunLoop currentRunLoop] getCFRunLoop], (__bridge CFStringRef)NSRunLoopCommonModes);
    CFRelease(_reachability);
}

#pragma mark - HUBConnectivityStateResolver

- (HUBConnectivityState)resolveConnectivityState
{
    if (self.connectivityState != nil) {
        return [self.connectivityState unsignedIntegerValue];
    }
    
    SCNetworkReachabilityFlags reachabilityFlags;
    
    if (!SCNetworkReachabilityGetFlags(self.reachability, &reachabilityFlags)) {
        return HUBConnectivityStateOffline;
    }
    
    HUBConnectivityState const connectivityState = [self connectivityStateFromReachabilityFlags:reachabilityFlags];
    self.connectivityState = @(connectivityState);
    return connectivityState;
}

- (void)addObserver:(id<HUBConnectivityStateResolverObserver>)observer
{
    [self.observers addObject:observer];
}

- (void)removeObserver:(id<HUBConnectivityStateResolverObserver>)observer
{
    [self.observers removeObject:observer];
}

#pragma mark - Private utilities

- (void)startObservingReachability
{
    SCNetworkReachabilityContext context = [self createReachabilityContext];
    SCNetworkReachabilitySetCallback(self.reachability, HUBReachabilityCallback, &context);
    SCNetworkReachabilitySetDispatchQueue(self.reachability, self.dispatchQueue);
    SCNetworkReachabilityScheduleWithRunLoop(self.reachability, [[NSRunLoop currentRunLoop] getCFRunLoop], (__bridge CFStringRef)NSRunLoopCommonModes);
}

- (SCNetworkReachabilityContext)createReachabilityContext
{
    __weak __typeof(self) weakSelf = self;
    
    SCNetworkReachabilityContext const context = {
        .version = 0,
        .info = (__bridge void *)weakSelf
    };
    
    return context;
}

- (HUBConnectivityState)connectivityStateFromReachabilityFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL const isReachable = flags & kSCNetworkFlagsReachable;
    BOOL const connectionRequired = flags & kSCNetworkFlagsConnectionRequired;
    
    if (!isReachable || connectionRequired) {
        return HUBConnectivityStateOffline;
    }
    
    return HUBConnectivityStateOnline;
}

- (void)notifyObserversOfChangedConnectivityState
{
    HUBPerformOnMainQueue(^{
        for (id<HUBConnectivityStateResolverObserver> const observer in self.observers) {
            [observer connectivityStateResolverStateDidChange:self];
        }
    });
}

@end

void HUBReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void *info) {
    HUBDefaultConnectivityStateResolver * const resolver = (__bridge HUBDefaultConnectivityStateResolver *)info;
    
    NSNumber * const previousConnectivityState = resolver.connectivityState;
    NSNumber * const newConnectivityState = @([resolver connectivityStateFromReachabilityFlags:flags]);
    
    if ([previousConnectivityState isEqual:newConnectivityState]) {
        return;
    }
    
    resolver.connectivityState = newConnectivityState;
    [resolver notifyObserversOfChangedConnectivityState];
}

NS_ASSUME_NONNULL_END
