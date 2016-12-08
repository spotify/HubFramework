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

#import "HUBViewModelUtilities.h"

#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBViewModelImplementation.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewModelUtilities

+ (id<HUBComponentModel>)createComponentModelWithIdentifier:(NSString *)identifier
                                                 customData:(nullable NSDictionary *)customData
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                  type:HUBComponentTypeBody
                                                                 index:0
                                                       groupIdentifier:nil
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:HUBComponentCategoryBanner
                                                                 title:@"title"
                                                              subtitle:@"subtitle"
                                                        accessoryTitle:nil
                                                       descriptionText:nil
                                                         mainImageData:nil
                                                   backgroundImageData:nil
                                                       customImageData:@{}
                                                                  icon:nil
                                                                target:nil
                                                              metadata:nil
                                                           loggingData:nil
                                                            customData:customData
                                                                parent:nil];
}

+ (id<HUBViewModel>)createViewModelWithIdentifier:(NSString *)identifier components:(NSArray<id<HUBComponentModel>> *)components
{
    UINavigationItem * const navigationItem = [[UINavigationItem alloc] initWithTitle:@"Title"];

    return [[HUBViewModelImplementation alloc] initWithIdentifier:identifier
                                                   navigationItem:navigationItem
                                             headerComponentModel:nil
                                              bodyComponentModels:components
                                           overlayComponentModels:@[]
                                                       customData:@{@"custom": @"data"}];
}

@end

NS_ASSUME_NONNULL_END
