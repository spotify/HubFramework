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

#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchema.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"
#import "HUBIcon.h"

@interface HUBComponentImageDataBuilderTests : XCTestCase

@property (nonatomic, strong) HUBComponentImageDataBuilderImplementation *builder;
@property (nonatomic, strong) HUBJSONSchemaImplementation *schema;

@end

@implementation HUBComponentImageDataBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                      iconImageResolver:iconImageResolver];
    
    self.builder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema iconImageResolver:iconImageResolver];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    self.builder.localImage = [UIImage new];
    self.builder.placeholderIconIdentifier = @"placeholder";
    self.builder.customData = @{@"custom": @"data"};
    
    NSString * const identifier = @"identifier";
    HUBComponentImageType const type = HUBComponentImageTypeCustom;
    
    HUBComponentImageDataImplementation * const imageData = [self.builder buildWithIdentifier:identifier type:type];
    
    XCTAssertEqual(imageData.identifier, identifier);
    XCTAssertEqual(imageData.type, type);
    XCTAssertEqualObjects(imageData.URL, self.builder.URL);
    XCTAssertEqual(imageData.localImage, self.builder.localImage);
    XCTAssertEqualObjects(imageData.placeholderIcon.identifier, @"placeholder");
    XCTAssertEqualObjects(imageData.customData, @{@"custom": @"data"});
}

- (void)testEmptyBuilderProducingNil
{
    XCTAssertNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testOnlyURLNotProducingNil
{
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testLocalImageOnlyNotProducingNil
{
    self.builder.localImage = [UIImage new];
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testOnlyPlaceholderIconIdentifierNotProducingNil
{
    self.builder.placeholderIconIdentifier = @"placeholder";
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testCustomDataOnlyNotProducingNil
{
    self.builder.customData = @{@"custom": @"data"};
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testNilIconImageResolverAlwaysResultingInNilPlaceholderIcon
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                      iconImageResolver:nil];
    
    self.builder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema iconImageResolver:nil];
    self.builder.placeholderIconIdentifier = @"placeholder";
    
    // Since icon is now nil, the builder itself should also return nil (since it doesn't contain any other data)
    XCTAssertNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
    
    self.builder.localImage = [UIImage new];
    HUBComponentImageDataImplementation * const imageData = [self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain];
    XCTAssertNotNil(imageData);
    XCTAssertNil(imageData.placeholderIcon);
}

- (void)testAddingJSONData
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://cdn.spotify.com/image"];
    
    NSDictionary * const dictionary = @{
        @"uri": imageURL.absoluteString,
        @"placeholder": @"place_holder",
        @"local": @"testImage",
        @"custom": @{
            @"key": @"value"
        }
    };
    
    [self.builder addDataFromJSONDictionary:dictionary];
    
    XCTAssertEqualObjects(self.builder.URL, imageURL);
    XCTAssertEqualObjects(self.builder.placeholderIconIdentifier, @"place_holder");
	XCTAssertEqualObjects(self.builder.customData, @{@"key": @"value"});    

    NSBundle * const bundle = [NSBundle bundleForClass:[self class]];
    UIImage * const expectedImage = [UIImage imageNamed:@"testImage" inBundle:bundle compatibleWithTraitCollection:nil];
    XCTAssertNotNil(expectedImage);
    XCTAssertEqualObjects(self.builder.localImage, expectedImage);
}

- (void)testAddingJSONDataNotOverridingExistingData
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://cdn.spotify.com/image"];
    UIImage * const localImage = [UIImage new];
    
    self.builder.placeholderIconIdentifier = @"placeholder";
    self.builder.URL = imageURL;
    self.builder.localImage = localImage;
    self.builder.customData = @{@"custom": @"data"};
    
    [self.builder addDataFromJSONDictionary:@{}];
    
    XCTAssertEqualObjects(self.builder.placeholderIconIdentifier, @"placeholder");
    XCTAssertEqualObjects(self.builder.URL, imageURL);
    XCTAssertEqualObjects(self.builder.localImage, localImage);
    XCTAssertEqualObjects(self.builder.customData, @{@"custom": @"data"});
}

- (void)testAddingNonDictionaryJSONDataReturnsError
{
    NSData * const stringData = [@"Not a dictionary" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil([self.builder addJSONData:stringData]);
    
    NSData * const arrayData = [NSJSONSerialization dataWithJSONObject:@[] options:(NSJSONWritingOptions)0 error:nil];
    XCTAssertNotNil([self.builder addJSONData:arrayData]);
}

- (void)testCopying
{
    UIImage * const localImage = [UIImage new];
    
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    self.builder.localImage = localImage;
    self.builder.placeholderIconIdentifier = @"placeholder";
    self.builder.customData = @{@"custom": @"data"};
    
    HUBComponentImageDataBuilderImplementation * const builderCopy = [self.builder copy];
    XCTAssertNotEqual(self.builder, builderCopy);
    
    XCTAssertEqualObjects(builderCopy.URL, [NSURL URLWithString:@"cdn.spotify.com/hub"]);
    XCTAssertEqualObjects(builderCopy.localImage, localImage);
    XCTAssertEqualObjects(builderCopy.placeholderIconIdentifier, @"placeholder");
    XCTAssertEqualObjects(builderCopy.customData, @{@"custom": @"data"});
}

@end
