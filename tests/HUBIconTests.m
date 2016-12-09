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

#import "HUBIconImplementation.h"
#import "HUBIconImageResolverMock.h"

@interface HUBIconTests : XCTestCase

@property (nonatomic, strong) HUBIconImageResolverMock *imageResolver;

@end

@implementation HUBIconTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.imageResolver = [HUBIconImageResolverMock new];
}

- (void)tearDown
{
    self.imageResolver = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testEquality
{
    HUBIconImageResolverMock *imageResolver1 = [HUBIconImageResolverMock new];
    HUBIconImageResolverMock *imageResolver2 = [HUBIconImageResolverMock new];
    XCTAssertNotEqualObjects(imageResolver1, imageResolver2);

    HUBIconImplementation * const icon1 = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                              imageResolver:imageResolver1
                                                                              isPlaceholder:NO];
    HUBIconImplementation * const icon2 = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                              imageResolver:imageResolver2
                                                                              isPlaceholder:NO];
    XCTAssertEqualObjects(icon1, icon2);
}

- (void)testIdentifierAssignment
{
    HUBIconImplementation * const icon = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                             imageResolver:self.imageResolver
                                                                             isPlaceholder:NO];
    
    XCTAssertEqualObjects(icon.identifier, @"id");
}

- (void)testResolvingComponentImage
{
    UIImage * const image = [UIImage new];
    self.imageResolver.imageForComponentIcons = image;
    
    HUBIconImplementation * const icon = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                             imageResolver:self.imageResolver
                                                                             isPlaceholder:NO];
    
    XCTAssertEqual([icon imageWithSize:CGSizeZero color:[UIColor redColor]], image);
}

- (void)testResolvingPlaceholderImage
{
    UIImage * const image = [UIImage new];
    self.imageResolver.imageForPlaceholderIcons = image;
    
    HUBIconImplementation * const icon = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                             imageResolver:self.imageResolver
                                                                             isPlaceholder:YES];
    
    XCTAssertEqual([icon imageWithSize:CGSizeZero color:[UIColor redColor]], image);
}

@end
