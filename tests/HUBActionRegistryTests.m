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

#import "HUBActionRegistryImplementation.h"
#import "HUBActionFactoryMock.h"
#import "HUBActionMock.h"
#import "HUBIdentifier.h"

@interface HUBActionRegistryTests : XCTestCase

@property (nonatomic, strong) HUBActionRegistryImplementation *actionRegistry;

@end

@implementation HUBActionRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.actionRegistry = [HUBActionRegistryImplementation registryWithDefaultSelectionAction];
}

- (void)tearDown
{
    self.actionRegistry = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testRegisteringFactoryAndCreatingAction
{
    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    
    HUBActionMock * const action = [[HUBActionMock alloc] initWithBlock:nil];
    HUBActionFactoryMock * const factory = [[HUBActionFactoryMock alloc] initWithActions:@{actionIdentifier.namePart: action}];
    [self.actionRegistry registerActionFactory:factory forNamespace:actionIdentifier.namespacePart];

    // These should be the same instance.
    XCTAssertTrue([self.actionRegistry createCustomActionForIdentifier:actionIdentifier] == action);
}

- (void)testRegisteringAlreadyRegisteredFactoryThrows
{
    HUBActionFactoryMock * const factoryA = [[HUBActionFactoryMock alloc] initWithActions:nil];
    [self.actionRegistry registerActionFactory:factoryA forNamespace:@"namespace"];
    
    HUBActionFactoryMock * const factoryB = [[HUBActionFactoryMock alloc] initWithActions:nil];
    XCTAssertThrows([self.actionRegistry registerActionFactory:factoryB forNamespace:@"namespace"]);
}

- (void)testUnregisteringFactory
{
    HUBActionFactoryMock * const factoryA = [[HUBActionFactoryMock alloc] initWithActions:nil];
    [self.actionRegistry registerActionFactory:factoryA forNamespace:@"namespace"];
    
    [self.actionRegistry unregisterActionFactoryForNamespace:@"namespace"];
    
    HUBActionFactoryMock * const factoryB = [[HUBActionFactoryMock alloc] initWithActions:nil];
    XCTAssertNoThrow([self.actionRegistry registerActionFactory:factoryB forNamespace:@"namespace"]);
}

@end
