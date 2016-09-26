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

#import "HUBComponentModelBuilderShowcaseSnapshotGenerator.h"

#import "HUBComponent.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentRegistryImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderShowcaseSnapshotGenerator ()

@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;

@end

@implementation HUBComponentModelBuilderShowcaseSnapshotGenerator

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
              mainImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)mainImageDataBuilder
        backgroundImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)backgroundImageDataBuilder
{
    NSParameterAssert(componentRegistry != nil);
    
    self = [super initWithModelIdentifier:nil
                                     type:HUBComponentTypeBody
                               JSONSchema:JSONSchema
                        componentDefaults:componentDefaults
                        iconImageResolver:iconImageResolver
                     mainImageDataBuilder:mainImageDataBuilder
               backgroundImageDataBuilder:backgroundImageDataBuilder];
    
    if (self) {
        _componentRegistry = componentRegistry;
    }
    
    return self;
}

#pragma mark - HUBComponentShowcaseSnapshotGenerator

- (UIImage *)generateShowcaseSnapshotForContainerViewSize:(CGSize)containerViewSize
{
    id<HUBComponentModel> const componentModel = [self buildForIndex:0 parent:nil];
    id<HUBComponent> const component = [self.componentRegistry createComponentForModel:componentModel];
    
    [component loadView];
    [component configureViewWithModel:componentModel containerViewSize:containerViewSize];
    
    CGSize const preferredViewSize = [component preferredViewSizeForDisplayingModel:componentModel containerViewSize:containerViewSize];
    UIView * const componentView = component.view;
    componentView.frame = CGRectMake(0, 0, preferredViewSize.width, preferredViewSize.height);
    
    UIWindow * const window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, containerViewSize.width, containerViewSize.height)];
    [window addSubview:componentView];
    
    UIGraphicsBeginImageContextWithOptions(componentView.bounds.size, NO, 0);
    [componentView layoutIfNeeded];
    [componentView drawViewHierarchyInRect:componentView.bounds afterScreenUpdates:YES];
    UIImage * const snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [componentView removeFromSuperview];
    
    return snapshotImage;
}

@end

NS_ASSUME_NONNULL_END
