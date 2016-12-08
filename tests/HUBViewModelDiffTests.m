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
#import "HUBViewModelUtilities.h"

#import <XCTest/XCTest.h>

@interface HUBViewModelDiffTests : XCTestCase

@end

@implementation HUBViewModelDiffTests

- (void)testInsertions
{
    id<HUBViewModel> firstViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                components:@[]];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
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
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:@{@"test": @5}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:@{@"test": @6}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
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
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
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
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-5" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-6" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-7" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-8" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-9" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-10" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:@{@"test": @1}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-30" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-5" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-6" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-7" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-9" customData:@{@"test": @2}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-10" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-13" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                 components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:7 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:9 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:8 inSection:0]]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 2);
}

- (void)testInsertionOfSingleComponentModelAtStartWithDataChanges
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-0" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:@{@"test": @1}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:@{@"test": @1}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:@{@"test": @1}]
    ];
    id<HUBViewModel> secondViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                 components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 3);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 1);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
}

- (void)testInsertionOfMultipleComponentModelsAtStartWithDataChanges
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-0" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-00" customData:nil],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:@{@"test": @1}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:@{@"test": @1}],
        [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:@{@"test": @1}]
    ];
    id<HUBViewModel> secondViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test"
                                                                                 components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 3);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
}

@end
