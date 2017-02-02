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

#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBComponentTargetImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBViewModelImplementation.h"

@interface HUBComponentModelTests : XCTestCase

@end

@implementation HUBComponentModelTests

- (void)testChildComponentModelAtIndex
{
    NSArray * const childModels = @[
        [self createComponentModelWithIdentifier:@"child1" index:0],
        [self createComponentModelWithIdentifier:@"child2" index:1]
    ];
    
    HUBComponentModelImplementation * const model = [self createComponentModelWithIdentifier:@"id" index:0];
    model.children = childModels;
    
    XCTAssertEqual([model childAtIndex:0], childModels[0]);
    XCTAssertEqual([model childAtIndex:1], childModels[1]);
    XCTAssertNil([model childAtIndex:2]);
}

- (void)testIdenticalInstancesAreEqual
{
    id<HUBComponentModel> (^createComponentModel)() = ^() {
        HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        
        NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.com/main.jpg"];
        id<HUBComponentImageData> const mainImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                                                   type:HUBComponentImageTypeMain
                                                                                                                    URL:mainImageURL
                                                                                                        placeholderIcon:nil
                                                                                                             localImage:nil
                                                                                                             customData:nil];
        
        NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.com/main.jpg"];
        id<HUBComponentImageData> const backgroundImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                                                         type:HUBComponentImageTypeBackground
                                                                                                                          URL:backgroundImageURL
                                                                                                              placeholderIcon:nil
                                                                                                                   localImage:nil
                                                                                                                   customData:nil];
        
        NSURL * const customImageURL = [NSURL URLWithString:@"https://image.com/custom.jpg"];
        id<HUBComponentImageData> const customImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                                                     type:HUBComponentImageTypeCustom
                                                                                                                      URL:customImageURL
                                                                                                          placeholderIcon:nil
                                                                                                               localImage:nil
                                                                                                               customData:nil];
        
        NSURL * const targetURI = [NSURL URLWithString:@"spotify:hub:framework"];
        HUBViewModelImplementation * const targetInitialViewModel = [[HUBViewModelImplementation alloc] initWithIdentifier:nil
                                                                                                            navigationItem:nil
                                                                                                      headerComponentModel:nil
                                                                                                       bodyComponentModels:@[]
                                                                                                    overlayComponentModels:@[]
                                                                                                                customData:nil];
        
        HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        
        id<HUBComponentTarget> const target = [[HUBComponentTargetImplementation alloc] initWithURI:targetURI
                                                                                   initialViewModel:targetInitialViewModel
                                                                                  actionIdentifiers:@[actionIdentifier]
                                                                                         customData:@{@"custom": @"data"}];
        
        return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
                                                                      type:HUBComponentTypeBody
                                                                     index:0
                                                           groupIdentifier:nil
                                                       componentIdentifier:componentIdentifier
                                                         componentCategory:HUBComponentCategoryRow
                                                                     title:@"Title"
                                                                  subtitle:@"Subtitle"
                                                            accessoryTitle:@"Accessory title"
                                                           descriptionText:@"Description text"
                                                             mainImageData:mainImageData
                                                       backgroundImageData:backgroundImageData
                                                           customImageData:@{@"custom": customImageData}
                                                                      icon:nil
                                                                    target:target
                                                                  metadata:@{@"meta": @"data"}
                                                               loggingData:@{@"logging": @"data"}
                                                                customData:@{@"custom": @"data"}
                                                                    parent:nil];
    };
    
    XCTAssertEqualObjects(createComponentModel(), createComponentModel());
}

- (void)testNonIdenticalInstancesAreNotEqual
{
    id<HUBComponentModel> (^createComponentModel)() = ^() {
        NSString * const identifier = [NSUUID UUID].UUIDString;
        HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        
        return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                      type:HUBComponentTypeBody
                                                                     index:0
                                                           groupIdentifier:nil
                                                       componentIdentifier:componentIdentifier
                                                         componentCategory:HUBComponentCategoryRow
                                                                     title:nil
                                                                  subtitle:nil
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
    
    XCTAssertNotEqualObjects(createComponentModel(), createComponentModel());
}

- (void)testChildWithIdentifier
{
    HUBComponentModelImplementation * const parent = [self createComponentModelWithIdentifier:@"parent" index:0];
    HUBComponentModelImplementation * const childA = [self createComponentModelWithIdentifier:@"childA" index:0];
    HUBComponentModelImplementation * const childB = [self createComponentModelWithIdentifier:@"childB" index:1];
    HUBComponentModelImplementation * const childC = [self createComponentModelWithIdentifier:@"childC" index:2];
    parent.children = @[childA, childB, childC];
    
    XCTAssertEqual([parent childWithIdentifier:@"childA"], childA);
    XCTAssertEqual([parent childWithIdentifier:@"childB"], childB);
    XCTAssertEqual([parent childWithIdentifier:@"childC"], childC);
    XCTAssertNil([parent childWithIdentifier:@"noChild"]);
}

- (void)testIndexPaths
{
    HUBComponentModelImplementation * const parent = [self createComponentModelWithIdentifier:@"parent" index:0];
    HUBComponentModelImplementation * const childA = [self createComponentModelWithIdentifier:@"childA" index:0 parent:parent];
    HUBComponentModelImplementation * const childB = [self createComponentModelWithIdentifier:@"childB" index:1 parent:parent];
    HUBComponentModelImplementation * const grandchild = [self createComponentModelWithIdentifier:@"grandchild" index:0 parent:childB];

    parent.children = @[childA, childB];
    childB.children = @[grandchild];

    XCTAssertEqualObjects(parent.indexPath, [NSIndexPath indexPathWithIndex:0]);

    NSUInteger childAIndexPathArray[] = {0,0};
    XCTAssertEqualObjects(childA.indexPath, [NSIndexPath indexPathWithIndexes:childAIndexPathArray length:2]);

    NSUInteger childBIndexPathArray[] = {0,1};
    XCTAssertEqualObjects(childB.indexPath, [NSIndexPath indexPathWithIndexes:childBIndexPathArray length:2]);

    NSUInteger grandchildIndexPathArray[] = {0,1,0};
    XCTAssertEqualObjects(grandchild.indexPath, [NSIndexPath indexPathWithIndexes:grandchildIndexPathArray length:3]);
}

- (void)testPropertiesThatDoNotAffectEquality
{
    HUBComponentModelImplementation * const parent1 = [self createComponentModelWithIdentifier:@"parent1" index:0];
    HUBComponentModelImplementation * const child1 = [self createComponentModelWithIdentifier:@"child" index:0 parent:parent1];
    parent1.children = @[child1];
    HUBComponentModelImplementation * const parent2 = [self createComponentModelWithIdentifier:@"parent2" index:1];
    HUBComponentModelImplementation * const child2 = [self createComponentModelWithIdentifier:@"child" index:1 parent:parent2];
    parent2.children = @[child2];

    XCTAssertNotEqualObjects(child1.parent, child2.parent);
    XCTAssertNotEqual(child1.index, child2.index);
    XCTAssertNotEqualObjects(child1.indexPath, child2.indexPath);

    // The parents, indices and index paths should not affect the children's equality.
    XCTAssertEqualObjects(child1, child2);
}

#pragma mark - Utilities

- (HUBComponentModelImplementation *)createComponentModelWithIdentifier:(NSString *)identifier index:(NSUInteger)index
{
    return [self createComponentModelWithIdentifier:identifier index:index parent:nil];
}

- (HUBComponentModelImplementation *)createComponentModelWithIdentifier:(NSString *)identifier index:(NSUInteger)index parent:(nullable HUBComponentModelImplementation *)parent
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBComponentTargetImplementation * const target = [[HUBComponentTargetImplementation alloc] initWithURI:nil
                                                                                           initialViewModel:nil
                                                                                          actionIdentifiers:nil
                                                                                                 customData:nil];
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                  type:HUBComponentTypeBody
                                                                 index:index
                                                       groupIdentifier:nil
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:HUBComponentCategoryRow
                                                                 title:nil
                                                              subtitle:nil
                                                        accessoryTitle:nil
                                                       descriptionText:nil
                                                         mainImageData:nil
                                                   backgroundImageData:nil
                                                       customImageData:@{}
                                                                  icon:nil
                                                                target:target
                                                              metadata:nil
                                                           loggingData:nil
                                                            customData:nil
                                                                parent:parent];
}

@end
