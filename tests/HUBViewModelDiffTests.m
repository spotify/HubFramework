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


#import "HUBViewModelDiff.h"
#import "HUBIdentifier.h"
#import "HUBComponentModelImplementation.h"
#import "HUBViewModelImplementation.h"

#import <XCTest/XCTest.h>

@interface HUBViewModelDiffTests : XCTestCase

@end

@implementation HUBViewModelDiffTests

- (id<HUBComponentModel>)createComponentModelWithIdentifier:(NSString *)identifier
                                                      index:(NSUInteger)index
                                                 customData:(nullable NSDictionary *)customData
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                  type:HUBComponentTypeBody
                                                                 index:index
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

- (id<HUBViewModel>)createViewModelWithIdentifier:(NSString *)identifier components:(NSArray<id<HUBComponentModel>> *)components
{
    return [[HUBViewModelImplementation alloc] initWithIdentifier:identifier
                                               navigationBarTitle:@"Title"
                                             headerComponentModel:nil
                                              bodyComponentModels:components
                                           overlayComponentModels:@[]
                                                     extensionURL:nil
                                                       customData:@{@"custom": @"data"}];
}

- (void)testInsertions
{
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                               components:@[]];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" index:0 customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" index:1 customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" index:2 customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" index:3 customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:3 inSection:0]]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 4);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
}

- (void)testReloads
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" index:0 customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" index:1 customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" index:2 customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" index:3 customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                            components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" index:0 customData:@{@"test": @5}],
        [self createComponentModelWithIdentifier:@"component-2" index:1 customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" index:2 customData:@{@"test": @6}],
        [self createComponentModelWithIdentifier:@"component-4" index:3 customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);

    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
}

- (void)testDeletions
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" index:0 customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" index:1 customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" index:2 customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" index:3 customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                            components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-2" index:0 customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" index:1 customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 2);
}

- (void)testComplexChangeSet
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" index:0 customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" index:1 customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" index:2 customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" index:3 customData:nil],
        [self createComponentModelWithIdentifier:@"component-5" index:4 customData:nil],
        [self createComponentModelWithIdentifier:@"component-6" index:5 customData:nil],
        [self createComponentModelWithIdentifier:@"component-7" index:6 customData:nil],
        [self createComponentModelWithIdentifier:@"component-8" index:7 customData:nil],
        [self createComponentModelWithIdentifier:@"component-9" index:8 customData:nil],
        [self createComponentModelWithIdentifier:@"component-10" index:9 customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                               components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" index:0 customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" index:1 customData:@{@"test": @1}],
        [self createComponentModelWithIdentifier:@"component-30" index:2 customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" index:3 customData:nil],
        [self createComponentModelWithIdentifier:@"component-7" index:4 customData:nil],
        [self createComponentModelWithIdentifier:@"component-5" index:5 customData:nil],
        [self createComponentModelWithIdentifier:@"component-6" index:6 customData:nil],
        [self createComponentModelWithIdentifier:@"component-9" index:7 customData:@{@"test": @2}],
        [self createComponentModelWithIdentifier:@"component-10" index:8 customData:nil],
        [self createComponentModelWithIdentifier:@"component-13" index:9 customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:7 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:9 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    HUBMoveIndexPath *moved = [[HUBMoveIndexPath alloc] initWithFrom:[NSIndexPath indexPathForItem:6 inSection:0] to:[NSIndexPath indexPathForItem:4 inSection:0]];
    XCTAssert([diff.movedBodyComponentIndexPaths containsObject:moved]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 2);
}

- (void)testDiffingPerformanceWithShallowComparisons
{
    NSUInteger const firstComponentCount = 10000;
    NSMutableArray<id<HUBComponentModel>> * const firstComponents = [NSMutableArray arrayWithCapacity:firstComponentCount];
    for (NSUInteger i = 0; i < firstComponentCount; i++) {
        id<HUBComponentModel> component = [self createComponentModelWithIdentifier:[NSString stringWithFormat:@"old-%@", @(i)] index:i customData:nil];
        [firstComponents addObject:component];
    }

    NSUInteger const newComponentCount = 7000;
    NSMutableArray<id<HUBComponentModel>> * const newComponents = [NSMutableArray arrayWithCapacity:newComponentCount];
    for (NSUInteger i = 0; i < newComponentCount; i++) {
        id<HUBComponentModel> component = [self createComponentModelWithIdentifier:[NSString stringWithFormat:@"new-%@", @(i)] index:i customData:nil];
        [newComponents addObject:component];
    }

    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"First"
                                                                components:firstComponents];

    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Second"
                                                                components:newComponents];

    [self measureBlock:^{
        [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    }];
}

- (void)testDiffingPerformanceWithDeepComparisons
{
    NSUInteger const firstComponentCount = 10000;
    NSMutableArray<id<HUBComponentModel>> * const firstComponents = [NSMutableArray arrayWithCapacity:firstComponentCount];
    for (NSUInteger i = 0; i < firstComponentCount; i++) {
        id<HUBComponentModel> component = [self createComponentModelWithIdentifier:[NSString stringWithFormat:@"component-%@", @(i)] index:i customData:nil];
        [firstComponents addObject:component];
    }

    NSMutableArray<id<HUBComponentModel>> * const newComponents = [firstComponents copy];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"First"
                                                                components:firstComponents];

    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Second"
                                                                components:newComponents];

    [self measureBlock:^{
        [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    }];
}

@end
