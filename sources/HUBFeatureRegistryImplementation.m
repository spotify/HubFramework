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

#import "HUBFeatureRegistryImplementation.h"

#import "HUBFeatureRegistration.h"
#import "HUBViewURIPredicate.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBFeatureRegistryImplementation ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBFeatureRegistration *> *registrationsByIdentifier;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *registrationIdentifierOrder;

@end

@implementation HUBFeatureRegistryImplementation

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _registrationsByIdentifier = [NSMutableDictionary new];
        _registrationIdentifierOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - API

- (nullable HUBFeatureRegistration *)featureRegistrationForViewURI:(NSURL *)viewURI
{
    for (NSString * const featureIdentifier in self.registrationIdentifierOrder) {
        HUBFeatureRegistration * const registration = self.registrationsByIdentifier[featureIdentifier];
        
        if ([registration.viewURIPredicate evaluateViewURI:viewURI]) {
            return registration;
        }
    }
    
    return nil;
}

#pragma mark - HUBFeatureRegistry

- (void)registerFeatureWithIdentifier:(NSString *)featureIdentifier
                     viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                                title:(NSString *)title
            contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                  contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
           customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                        actionHandler:(nullable id<HUBActionHandler>)actionHandler
          viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler
{
    [self registerFeatureWithIdentifier:featureIdentifier
                       viewURIPredicate:viewURIPredicate
                                  title:title
              contentOperationFactories:contentOperationFactories
                    contentReloadPolicy:contentReloadPolicy
             customJSONSchemaIdentifier:customJSONSchemaIdentifier
                          actionHandler:actionHandler
            viewControllerScrollHandler:viewControllerScrollHandler
                                options:nil];
}

- (void)registerFeatureWithIdentifier:(NSString *)featureIdentifier
                     viewURIPredicate:(HUBViewURIPredicate *)viewURIPredicate
                                title:(NSString *)title
            contentOperationFactories:(NSArray<id<HUBContentOperationFactory>> *)contentOperationFactories
                  contentReloadPolicy:(nullable id<HUBContentReloadPolicy>)contentReloadPolicy
           customJSONSchemaIdentifier:(nullable NSString *)customJSONSchemaIdentifier
                        actionHandler:(nullable id<HUBActionHandler>)actionHandler
          viewControllerScrollHandler:(nullable id<HUBViewControllerScrollHandler>)viewControllerScrollHandler
                              options:(nullable NSDictionary<NSString *, NSString *> *)options
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(viewURIPredicate != nil);
    NSParameterAssert(title != nil);
    
    NSAssert(self.registrationsByIdentifier[featureIdentifier] == nil,
             @"Attempted to register a Hub Framework feature for an identifier that is already registered: %@",
             featureIdentifier);
    
    NSAssert(contentOperationFactories.count > 0,
             @"Attempted to register a Hub Framework feature without any content operation factories. Feature identifier: %@",
             featureIdentifier);
    
    HUBFeatureRegistration * const registration = [[HUBFeatureRegistration alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                      title:title
                                                                                           viewURIPredicate:viewURIPredicate
                                                                                  contentOperationFactories:contentOperationFactories
                                                                                        contentReloadPolicy:contentReloadPolicy
                                                                                 customJSONSchemaIdentifier:customJSONSchemaIdentifier
                                                                                              actionHandler:actionHandler
                                                                                viewControllerScrollHandler:viewControllerScrollHandler
                                                                                                    options:options];
    
    self.registrationsByIdentifier[registration.featureIdentifier] = registration;
    [self.registrationIdentifierOrder addObject:registration.featureIdentifier];
}

- (void)registerFeature:(HUBFeatureRegistration *)feature
{
    [self registerFeatureWithIdentifier:feature.featureIdentifier
                       viewURIPredicate:feature.viewURIPredicate
                                  title:feature.featureTitle
              contentOperationFactories:feature.contentOperationFactories
                    contentReloadPolicy:feature.contentReloadPolicy
             customJSONSchemaIdentifier:feature.customJSONSchemaIdentifier
                          actionHandler:feature.actionHandler
            viewControllerScrollHandler:feature.viewControllerScrollHandler];
}

- (void)unregisterFeatureWithIdentifier:(NSString *)featureIdentifier
{
    HUBFeatureRegistration * const registration = self.registrationsByIdentifier[featureIdentifier];
    
    if (registration == nil) {
        return;
    }
    
    self.registrationsByIdentifier[featureIdentifier] = nil;
}

@end

NS_ASSUME_NONNULL_END
