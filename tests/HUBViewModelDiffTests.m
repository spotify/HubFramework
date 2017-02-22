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

- (void)testIdenticalModelMyers
{
    [self runIdenticalModelTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testIdenticalModelLCS
{
    [self runIdenticalModelTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runIdenticalModelTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
{
    NSArray<id<HUBComponentModel>> *components = @[
                                                   [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-1" customData:nil],
                                                   [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-2" customData:nil],
                                                   [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-3" customData:nil],
                                                   [HUBViewModelUtilities createComponentModelWithIdentifier:@"component-4" customData:nil]
                                                   ];
    id<HUBViewModel> viewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test" components:components];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:viewModel toViewModel:viewModel algorithm:algorithm];
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssertFalse(diff.hasBodyChanges);
}

- (void)testInsertionsMyers
{
    [self runInsertionsTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testInsertionsLCS
{
    [self runInsertionsTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runInsertionsTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
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

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel algorithm:algorithm];
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:3 inSection:0]]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 4);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssertTrue(diff.hasBodyChanges);
}

- (void)testReloadsMyers
{
    [self runReloadsTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testReloadsLCS
{
    [self runReloadsTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runReloadsTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
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

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel algorithm:algorithm];
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);

    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssertTrue(diff.hasBodyChanges);
}

- (void)testDeletionsMyers
{
    [self runDeletionsTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testDeletionsLCS
{
    [self runDeletionsTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runDeletionsTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
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

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel algorithm:algorithm];
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 0);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 2);
    XCTAssertTrue(diff.hasBodyChanges);
}

- (void)testComplexChangeSetMyers
{
    [self runComplextChangeSetTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testComplexChangeSetLCS
{
    [self runComplextChangeSetTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runComplextChangeSetTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
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

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel algorithm:algorithm];
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.deletedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:7 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:9 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:8 inSection:0]]);
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 2);
    XCTAssertTrue(diff.hasBodyChanges);
}

- (void)testInsertionOfSingleComponentModelAtStartWithDataChangesMyers
{
    [self runInsertionOfSingleComponentModelAtStartWithDataChangesTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testInsertionOfSingleComponentModelAtStartWithDataChangesLCS
{
    [self runInsertionOfSingleComponentModelAtStartWithDataChangesTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runInsertionOfSingleComponentModelAtStartWithDataChangesTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
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

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel algorithm:algorithm];
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 3);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 1);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssertTrue(diff.hasBodyChanges);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
}

- (void)testInsertionOfMultipleComponentModelsAtStartWithDataChangesMyers
{
    [self runInsertionOfMultipleComponentModelsAtStartWithDataChangesTestWithAlgorithm:HUBDiffMyersAlgorithm];
}

- (void)testInsertionOfMultipleComponentModelsAtStartWithDataChangesLCS
{
    [self runInsertionOfMultipleComponentModelsAtStartWithDataChangesTestWithAlgorithm:HUBDiffLCSAlgorithm];
}

- (void)runInsertionOfMultipleComponentModelsAtStartWithDataChangesTestWithAlgorithm:(HUBDiffAlgorithm)algorithm
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

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel algorithm:algorithm];
    XCTAssert(diff.reloadedBodyComponentIndexPaths.count == 3);
    XCTAssert(diff.insertedBodyComponentIndexPaths.count == 2);
    XCTAssert(diff.deletedBodyComponentIndexPaths.count == 0);
    XCTAssertTrue(diff.hasBodyChanges);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.insertedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:0 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:1 inSection:0]]);
    XCTAssert([diff.reloadedBodyComponentIndexPaths containsObject:[NSIndexPath indexPathForItem:2 inSection:0]]);
}

#pragma mark - Header changes tests

- (id<HUBViewModel>)viewModelWithHeaderComponentName:(NSString *)headerComponentIdentifierName
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"Test" name:headerComponentIdentifierName];
    id<HUBComponentModel> headerComponent = [HUBViewModelUtilities createComponentModelWithIdentifier:@"header" type:HUBComponentTypeHeader componentIdentifier:componentIdentifier customData:nil];
    id<HUBViewModel> viewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test" bodyComponents:@[] headerComponent:headerComponent];
    return viewModel;
}

- (void)testHeaderChangeIsFalseWhenFromAndToAreEmpty
{
    id<HUBViewModel> fromViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test" bodyComponents:@[] headerComponent:nil];
    id<HUBViewModel> toViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test" bodyComponents:@[] headerComponent:nil];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
    XCTAssertFalse(diff.hasHeaderChanges);
}

- (void)testHeaderChangeIsTrueWhenFromAndToAreDifferent
{
    id<HUBViewModel> fromViewModel = [self viewModelWithHeaderComponentName:@"I"];
    id<HUBViewModel> toViewModel = [self viewModelWithHeaderComponentName:@"L"];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
    XCTAssertTrue(diff.hasHeaderChanges);
}

- (void)testHeaderChangeIsFalseWhenFromAndToAreSame
{
    id<HUBViewModel> fromViewModel = [self viewModelWithHeaderComponentName:@"U"];
    id<HUBViewModel> toViewModel = [self viewModelWithHeaderComponentName:@"U"];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
    XCTAssertFalse(diff.hasHeaderChanges);
}

- (void)testHeaderChangeIsTrueWhenFromIsEmpty
{
    id<HUBViewModel> fromViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test" bodyComponents:@[] headerComponent:nil];
    id<HUBViewModel> toViewModel = [self viewModelWithHeaderComponentName:@"C"];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
    XCTAssertTrue(diff.hasHeaderChanges);
}

- (void)testHeaderChangeIsTrueWhenToIsEmpty
{
    id<HUBViewModel> fromViewModel = [self viewModelWithHeaderComponentName:@"T"];
    id<HUBViewModel> toViewModel = [HUBViewModelUtilities createViewModelWithIdentifier:@"Test" bodyComponents:@[] headerComponent:nil];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:fromViewModel toViewModel:toViewModel algorithm:HUBDiffMyersAlgorithm];
    XCTAssertTrue(diff.hasHeaderChanges);
}

@end
