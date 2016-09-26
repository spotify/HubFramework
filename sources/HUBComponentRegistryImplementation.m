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

#import "HUBComponentRegistryImplementation.h"

#import "HUBComponent.h"
#import "HUBIdentifier.h"
#import "HUBComponentFactory.h"
#import "HUBComponentFactoryShowcaseNameProvider.h"
#import "HUBComponentModel.h"
#import "HUBComponentFallbackHandler.h"
#import "HUBComponentModelBuilderShowcaseSnapshotGenerator.h"
#import "HUBJSONSchemaRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentRegistryImplementation ()

@property (nonatomic, strong, readonly) id<HUBComponentFallbackHandler> fallbackHandler;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, readonly) HUBJSONSchemaRegistryImplementation *JSONSchemaRegistry;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBComponentFactory>> *componentFactories;

@end

@implementation HUBComponentRegistryImplementation

- (instancetype)initWithFallbackHandler:(id<HUBComponentFallbackHandler>)fallbackHandler
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                     JSONSchemaRegistry:(HUBJSONSchemaRegistryImplementation *)JSONSchemaRegistry
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    NSParameterAssert(fallbackHandler != nil);
    NSParameterAssert(componentDefaults != nil);
    NSParameterAssert(JSONSchemaRegistry != nil);
    
    self = [super init];
    
    if (self) {
        _fallbackHandler = fallbackHandler;
        _componentDefaults = componentDefaults;
        _JSONSchemaRegistry = JSONSchemaRegistry;
        _iconImageResolver = iconImageResolver;
        _componentFactories = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - API

- (id<HUBComponent>)createComponentForModel:(id<HUBComponentModel>)model
{
    id<HUBComponentFactory> const factory = self.componentFactories[model.componentIdentifier.namespacePart];
    id<HUBComponent> const component = [factory createComponentForName:model.componentIdentifier.namePart];
    
    if (component != nil) {
        return component;
    }
    
    return [self.fallbackHandler createFallbackComponentForCategory:model.componentCategory];
}

#pragma mark - HUBComponentRegistry

- (void)registerComponentFactory:(id<HUBComponentFactory>)componentFactory forNamespace:(NSString *)componentNamespace
{
    NSAssert(self.componentFactories[componentNamespace] == nil,
             @"Attempted to register a component factory for a namespace that is already registered: %@",
             componentNamespace);

    self.componentFactories[componentNamespace] = componentFactory;
}

- (void)unregisterComponentFactoryForNamespace:(NSString *)componentNamespace
{
    self.componentFactories[componentNamespace] = nil;
}

#pragma mark - HUBComponentShowcaseManager

- (NSArray<HUBIdentifier *> *)showcaseableComponentIdentifiers
{
    NSMutableArray<HUBIdentifier *> * const componentIdentifiers = [NSMutableArray new];
    
    for (NSString * const namespace in self.componentFactories) {
        id<HUBComponentFactory> const factory = self.componentFactories[namespace];
        
        if (![factory conformsToProtocol:@protocol(HUBComponentFactoryShowcaseNameProvider)]) {
            continue;
        }
        
        NSArray<NSString *> * const names = ((id<HUBComponentFactoryShowcaseNameProvider>)factory).showcaseableComponentNames;
        
        for (NSString * const name in names) {
            HUBIdentifier * const identifier = [[HUBIdentifier alloc] initWithNamespace:namespace name:name];
            [componentIdentifiers addObject:identifier];
        }
    }
    
    return [componentIdentifiers copy];
}

- (nullable NSString *)showcaseNameForComponentIdentifier:(HUBIdentifier *)componentIdentifier
{
    id<HUBComponentFactory> const factory = self.componentFactories[componentIdentifier.namespacePart];
    
    if (![factory conformsToProtocol:@protocol(HUBComponentFactoryShowcaseNameProvider)]) {
        return nil;
    }
    
    id<HUBComponentFactoryShowcaseNameProvider> const showcaseNameProvider = (id<HUBComponentFactoryShowcaseNameProvider>)factory;
    return [showcaseNameProvider showcaseNameForComponentName:componentIdentifier.namePart];
}

- (id<HUBComponentModelBuilder, HUBComponentShowcaseSnapshotGenerator>)createShowcaseSnapshotComponentModelBuilder
{
    return [[HUBComponentModelBuilderShowcaseSnapshotGenerator alloc] initWithJSONSchema:self.JSONSchemaRegistry.defaultSchema
                                                                       componentRegistry:self
                                                                       componentDefaults:self.componentDefaults
                                                                       iconImageResolver:self.iconImageResolver
                                                                    mainImageDataBuilder:nil
                                                              backgroundImageDataBuilder:nil];
}

@end

NS_ASSUME_NONNULL_END
