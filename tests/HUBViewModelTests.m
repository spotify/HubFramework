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

#import <XCTest/XCTest.h>

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBComponentCategories.h"

@interface HUBViewModelTests : XCTestCase

@end

@implementation HUBViewModelTests

- (void)testIdenticalInstancesAreEqual
{
    id<HUBViewModel>(^createViewModel)() = ^{
        id<HUBComponentModel> (^createComponentModel)() = ^{
            HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
            
            return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
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
                                                                    customData:nil
                                                                        parent:nil];
        };
        
        NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/viewmodelextension"];
        
        return [[HUBViewModelImplementation alloc] initWithIdentifier:@"identifier"
                                                   navigationBarTitle:@"title"
                                                 headerComponentModel:createComponentModel()
                                                  bodyComponentModels:@[createComponentModel()]
                                               overlayComponentModels:@[createComponentModel()]
                                                         extensionURL:extensionURL
                                                           customData:@{@"custom": @"data"}];
    };
    
    XCTAssertEqualObjects(createViewModel(), createViewModel());
}

- (void)testNonIdentificalInstancesAreNotEqual
{
    id<HUBViewModel>(^createViewModel)() = ^{
        id<HUBComponentModel> (^createComponentModel)() = ^{
            HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
            
            return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
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
                                                                    customData:nil
                                                                        parent:nil];
        };
        
        NSString * const title = [NSUUID UUID].UUIDString;
        NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/viewmodelextension"];
        
        return [[HUBViewModelImplementation alloc] initWithIdentifier:@"identifier"
                                                   navigationBarTitle:title
                                                 headerComponentModel:createComponentModel()
                                                  bodyComponentModels:@[createComponentModel()]
                                               overlayComponentModels:@[createComponentModel()]
                                                         extensionURL:extensionURL
                                                           customData:@{@"custom": @"data"}];
    };
    
    XCTAssertNotEqualObjects(createViewModel(), createViewModel());
}

@end
