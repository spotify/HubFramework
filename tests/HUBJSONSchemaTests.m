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

#import "HUBJSONSchemaImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModel.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"

@interface HUBJSONSchemaTests : XCTestCase

@end

@implementation HUBJSONSchemaTests

- (void)testViewModelFromJSONDictionary
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    
    HUBJSONSchemaImplementation * const schema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                              iconImageResolver:iconImageResolver];
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:schema
                                                                                                    componentDefaults:componentDefaults
                                                                                                    iconImageResolver:iconImageResolver];
    
    NSDictionary * const dictionary = @{
        @"body": @[
            @{
                @"component": @"namespace:name",
                @"title": @"A title"
            }
        ]
    };
    
    [builder addJSONDictionary:dictionary];
    
    id<HUBViewModel> const viewModelFromSchema = [schema viewModelFromJSONDictionary:dictionary];
    id<HUBViewModel> const viewModelFromBuilder = [builder build];
    
    XCTAssertEqual(viewModelFromSchema.bodyComponentModels.count, viewModelFromBuilder.bodyComponentModels.count);
    XCTAssertEqualObjects([viewModelFromSchema.bodyComponentModels firstObject].title, [viewModelFromBuilder.bodyComponentModels firstObject].title);
}

- (void)testCopy
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBJSONSchema> const schema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults iconImageResolver:iconImageResolver];
    id<HUBJSONSchema> const copy = [schema copy];
    
    // Assert that the copied sub schemas are not the same instance as the original ones
    XCTAssertNotEqual(schema.viewModelSchema, copy.viewModelSchema);
    XCTAssertNotEqual(schema.componentModelSchema, copy.componentModelSchema);
    XCTAssertNotEqual(schema.componentImageDataSchema, copy.componentImageDataSchema);
}

@end
