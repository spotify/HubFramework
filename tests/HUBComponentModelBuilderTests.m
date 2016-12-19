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

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentTargetBuilder.h"
#import "HUBComponentTarget.h"
#import "HUBViewModel.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"
#import "HUBIcon.h"

@interface HUBComponentModelBuilderTests : XCTestCase

@property (nonatomic, copy) NSString *modelIdentifier;
@property (nonatomic, strong) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong) HUBComponentModelBuilderImplementation *builder;

@end

@implementation HUBComponentModelBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.modelIdentifier = @"model";
    self.componentDefaults = [HUBComponentDefaults defaultsForTesting];
    
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults iconImageResolver:iconImageResolver];
    
    self.builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:self.modelIdentifier
                                                                                      type:HUBComponentTypeBody
                                                                                JSONSchema:JSONSchema
                                                                         componentDefaults:self.componentDefaults
                                                                         iconImageResolver:iconImageResolver
                                                                      mainImageDataBuilder:nil
                                                                backgroundImageDataBuilder:nil];
}

- (void)tearDown
{
    self.modelIdentifier = nil;
    self.componentDefaults = nil;
    self.builder = nil;

    [super tearDown];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    XCTAssertEqualObjects(self.builder.modelIdentifier, self.modelIdentifier);
    
    self.builder.componentNamespace = @"namespace";
    self.builder.componentName = @"name";
    self.builder.componentCategory = @"category";
    self.builder.title = @"title";
    self.builder.subtitle = @"subtitle";
    self.builder.accessoryTitle = @"accessory";
    self.builder.descriptionText = @"description";
    self.builder.mainImageDataBuilder.placeholderIconIdentifier = @"main";
    self.builder.backgroundImageDataBuilder.placeholderIconIdentifier = @"background";
    self.builder.targetBuilder.URI = [NSURL URLWithString:@"spotify:hub"];
    self.builder.customData = @{@"key": @"value"};
    self.builder.loggingData = @{@"logging": @"data"};
    
    NSUInteger const modelIndex = 5;
    id<HUBComponentModel> const model = [self.builder buildForIndex:modelIndex parent:nil];
    
    XCTAssertEqual(model.type, HUBComponentTypeBody);
    XCTAssertEqualObjects(model.componentIdentifier.namespacePart, @"namespace");
    XCTAssertEqualObjects(model.componentIdentifier.namePart, @"name");
    XCTAssertEqualObjects(model.componentCategory, @"category");
    XCTAssertEqual(model.index, modelIndex);
    XCTAssertEqualObjects(model.title, self.builder.title);
    XCTAssertEqualObjects(model.subtitle, self.builder.subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, self.builder.accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, self.builder.descriptionText);
    XCTAssertEqualObjects(model.mainImageData.placeholderIcon.identifier, @"main");
    XCTAssertEqualObjects(model.backgroundImageData.placeholderIcon.identifier, @"background");
    XCTAssertEqualObjects(model.target.URI, self.builder.targetBuilder.URI);
    XCTAssertEqualObjects(model.customData, self.builder.customData);
    XCTAssertEqualObjects(model.loggingData, self.builder.loggingData);
    XCTAssertNil(model.parent);
}

- (void)testOverridingDefaultComponentNameNamespaceAndCategory
{
    self.builder.componentNamespace = @"namespace-override";
    self.builder.componentName = @"name-override";
    self.builder.componentCategory = @"category-override";
    
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertEqualObjects(model.componentIdentifier.namespacePart, @"namespace-override");
    XCTAssertEqualObjects(model.componentIdentifier.namePart, @"name-override");
    XCTAssertEqualObjects(model.componentCategory, @"category-override");
}

- (void)testDefaultImageTypes
{
    self.builder.componentNamespace = @"component";
    self.builder.mainImageDataBuilder.placeholderIconIdentifier = @"placeholder";
    self.builder.backgroundImageDataBuilder.placeholderIconIdentifier = @"placeholder";
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    
    XCTAssertEqual(model.mainImageData.type, HUBComponentImageTypeMain);
    XCTAssertEqual(model.backgroundImageData.type, HUBComponentImageTypeBackground);
}

- (void)testImageConvenienceAPIs
{
    self.builder.componentName = @"component";
    self.builder.mainImageURL = [NSURL URLWithString:@"https://spotify.mainImage"];
    self.builder.mainImage = [UIImage new];
    self.builder.backgroundImageURL = [NSURL URLWithString:@"https://spotify.mainImage"];
    self.builder.backgroundImage = [UIImage new];
    
    XCTAssertEqualObjects(self.builder.mainImageDataBuilder.URL, self.builder.mainImageURL);
    XCTAssertEqual(self.builder.mainImageDataBuilder.localImage, self.builder.mainImage);
    XCTAssertEqualObjects(self.builder.backgroundImageDataBuilder.URL, self.builder.backgroundImageURL);
    XCTAssertEqual(self.builder.backgroundImageDataBuilder.localImage, self.builder.backgroundImage);
}

- (void)testCustomImageDataBuilder
{
    self.builder.componentName = @"component";
    
    NSString * const customImageIdentifier = @"customImage";
    
    XCTAssertFalse([self.builder builderExistsForCustomImageDataWithIdentifier:customImageIdentifier]);
    
    id<HUBComponentImageDataBuilder> const imageDataBuilder = [self.builder builderForCustomImageDataWithIdentifier:customImageIdentifier];
    XCTAssertTrue([self.builder builderExistsForCustomImageDataWithIdentifier:customImageIdentifier]);
    imageDataBuilder.placeholderIconIdentifier = @"placeholder";
    
    NSString * const emptyCustomImageBuilderIdentifier = @"empty";
    [self.builder builderForCustomImageDataWithIdentifier:emptyCustomImageBuilderIdentifier];
    
    id<HUBComponentModel> const componentModel = [self.builder buildForIndex:0 parent:nil];
    id<HUBComponentImageData> const customImageData = componentModel.customImageData[customImageIdentifier];
    
    XCTAssertEqualObjects(customImageData.identifier, customImageIdentifier);
    XCTAssertEqual(customImageData.type, HUBComponentImageTypeCustom);
    XCTAssertEqualObjects(customImageData.placeholderIcon.identifier, @"placeholder");
    
    XCTAssertNil(componentModel.customImageData[emptyCustomImageBuilderIdentifier]);
}

- (void)testNilIconImageResolverAlwaysResultingInNilIcon
{
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults
                                                                                      iconImageResolver:nil];
    
    self.builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:self.modelIdentifier
                                                                                      type:HUBComponentTypeBody
                                                                                JSONSchema:JSONSchema
                                                                         componentDefaults:self.componentDefaults
                                                                         iconImageResolver:nil
                                                                      mainImageDataBuilder:nil
                                                                backgroundImageDataBuilder:nil];
    
    self.builder.iconIdentifier = @"icon";
    
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertNotNil(model);
    XCTAssertNil(model.icon);
}

- (void)testCreatingChild
{
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:childModelIdentifier];
    
    XCTAssertEqualObjects(childBuilder.modelIdentifier, childModelIdentifier);
    XCTAssertTrue([self.builder builderExistsForChildWithIdentifier:childModelIdentifier]);
}

- (void)testChildComponentModelBuilderReuse
{
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:childModelIdentifier];
    
    XCTAssertEqual([self.builder builderForChildWithIdentifier:childModelIdentifier], childBuilder);
}

- (void)testChildTypeSameAsParent
{
    [self.builder builderForChildWithIdentifier:@"id"];
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertEqual(model.children[0].type, model.type);
}

- (void)testChildPreferredIndexRespected
{
    self.builder.componentName = @"component";
    
    NSString * const childIdentifierA = @"componentA";
    id<HUBComponentModelBuilder> const childBuilderA = [self.builder builderForChildWithIdentifier:childIdentifierA];
    childBuilderA.preferredIndex = @2;
    childBuilderA.componentName = @"component";

    NSString * const childIdentifierB= @"componentB";
    id<HUBComponentModelBuilder> const childBuilderB = [self.builder builderForChildWithIdentifier:childIdentifierB];
    childBuilderB.componentName = @"component";

    NSString * const childIdentifierC = @"componentC";
    id<HUBComponentModelBuilder> const childBuilderC = [self.builder builderForChildWithIdentifier:childIdentifierC];
    childBuilderC.preferredIndex = @3;
    childBuilderC.componentName = @"component";

    NSString * const childIdentifierD = @"componentD";
    id<HUBComponentModelBuilder> const childBuilderD = [self.builder builderForChildWithIdentifier:childIdentifierD];
    childBuilderD.preferredIndex = @1;
    childBuilderD.componentName = @"component";

    NSString * const childIdentifierE = @"componentE";
    id<HUBComponentModelBuilder> const childBuilderE = [self.builder builderForChildWithIdentifier:childIdentifierE];
    childBuilderE.preferredIndex = @0;
    childBuilderE.componentName = @"component";

    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertEqual(model.children.count, (NSUInteger)5);
    XCTAssertEqualObjects(model.children[0].identifier, childIdentifierE);
    XCTAssertEqual(model.children[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.children[1].identifier, childIdentifierD);
    XCTAssertEqual(model.children[1].index, (NSUInteger)1);
    XCTAssertEqualObjects(model.children[2].identifier, childIdentifierA);
    XCTAssertEqual(model.children[2].index, (NSUInteger)2);
    XCTAssertEqualObjects(model.children[3].identifier, childIdentifierC);
    XCTAssertEqual(model.children[3].index, (NSUInteger)3);
}

- (void)testChildOutOfBoundsPreferredIndexHandled
{
    self.builder.componentName = @"component";
    
    NSString * const childIdentifier = @"child";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:childIdentifier];
    childBuilder.componentName = @"component";
    childBuilder.preferredIndex = @99;

    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertEqual(model.children.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.children[0].identifier, childIdentifier);
    XCTAssertEqual(model.children[0].index, (NSUInteger)0);
}

- (void)testRemovingChildComponentModel
{
    NSString * const childIdentifier = @"child";
    
    [self.builder builderForChildWithIdentifier:childIdentifier].componentName = @"component";
    XCTAssertTrue([self.builder builderExistsForChildWithIdentifier:childIdentifier]);

    NSUInteger childBuilderCountBefore = [self.builder allChildBuilders].count;
    [self.builder removeBuilderForChildWithIdentifier:childIdentifier];
    XCTAssertFalse([self.builder builderExistsForChildWithIdentifier:childIdentifier]);
    XCTAssertEqual([self.builder allChildBuilders].count, childBuilderCountBefore - 1);
}

- (void)testRemovingAllChildComponentModelBuilders
{
    self.builder.componentName = @"component";
    
    [self.builder builderForChildWithIdentifier:@"child1"].componentName = @"component";
    [self.builder builderForChildWithIdentifier:@"child2"].componentName = @"component";
    [self.builder builderForChildWithIdentifier:@"child3"].componentName = @"component";
    
    XCTAssertEqual([self.builder buildForIndex:0 parent:nil].children.count, (NSUInteger)3);
    
    [self.builder removeAllChildBuilders];
    
    XCTAssertEqual([self.builder buildForIndex:0 parent:nil].children.count, (NSUInteger)0);
}

- (void)testChildReferenceToParent
{
    id<HUBComponentModel> const parent = [self.builder buildForIndex:0 parent:nil];
    id<HUBComponentModel> const child = [self.builder buildForIndex:0 parent:parent];
    id<HUBComponentModel> const actualParent = child.parent;
    
    XCTAssertEqual(parent, actualParent);
}

- (void)testChildGrouping
{
    [self.builder builderForChildWithIdentifier:@"childA"].groupIdentifier = @"groupA";
    [self.builder builderForChildWithIdentifier:@"childB"].groupIdentifier = @"groupA";
    [self.builder builderForChildWithIdentifier:@"childC"].groupIdentifier = @"groupB";
    [self.builder builderForChildWithIdentifier:@"childD"].groupIdentifier = @"groupB";
    
    id<HUBComponentModel> const parent = [self.builder buildForIndex:0 parent:nil];
    
    id<HUBComponentModel> const childA = [parent childWithIdentifier:@"childA"];
    id<HUBComponentModel> const childB = [parent childWithIdentifier:@"childB"];
    NSArray<id<HUBComponentModel>> * const groupA = @[childA, childB];
    
    XCTAssertEqualObjects(childA.groupIdentifier, @"groupA");
    XCTAssertEqualObjects(childB.groupIdentifier, @"groupA");
    
    id<HUBComponentModel> const childC = [parent childWithIdentifier:@"childC"];
    id<HUBComponentModel> const childD = [parent childWithIdentifier:@"childD"];
    NSArray<id<HUBComponentModel>> * const groupB = @[childC, childD];
    
    XCTAssertEqualObjects(childC.groupIdentifier, @"groupB");
    XCTAssertEqualObjects(childD.groupIdentifier, @"groupB");
    
    XCTAssertEqualObjects([parent childrenInGroupWithIdentifier:@"groupA"], groupA);
    XCTAssertEqualObjects([parent childrenInGroupWithIdentifier:@"groupB"], groupB);
}

- (void)testAddingJSONDataAndModelSerialization
{
    NSString * const modelIdentifier = @"model";
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"component"];
    NSString * const title = @"A title";
    NSString * const subtitle = @"A subtitle";
    NSString * const accessoryTitle = @"An accessory title";
    NSString * const descriptionText = @"A description text";
    NSString * const mainImagePlaceholderIdentifier = @"mainPlaceholder";
    NSString * const backgroundImagePlaceholderIdentifier = @"backgroundPlaceholder";
    NSString * const customImageIdentifier = @"hologram";
    NSString * const customImagePlaceholderIdentifier = @"hologramPlaceholder";
    NSString * const iconIdentifier = @"icon";
    NSURL * const targetURL = [NSURL URLWithString:@"spotify:hub:target"];
    NSString * const targetTitle = @"Target title";
    NSString * const targetViewIdentifier = @"identifier";
    HUBIdentifier * const targetActionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"action"];
    NSDictionary * const metadata = @{@"meta": @"data"};
    NSDictionary * const loggingData = @{@"logging": @"data"};
    NSDictionary * const customData = @{@"custom": @"data"};
    NSString * const child1ModelIdentifier = @"ChildComponent1";
    HUBIdentifier * const child1ComponentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"child" name:@"component1"];
    NSString * const child2ModelIdentifier = @"ChildComponent2";
    HUBIdentifier * const child2ComponentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"child" name:@"component2"];
    
    NSDictionary * const dictionary = @{
        @"id": modelIdentifier,
        @"component": @{
            @"id": componentIdentifier.identifierString,
            @"category": @"mainCategory"
        },
        @"text": @{
            @"title": title,
            @"subtitle": subtitle,
            @"accessory": accessoryTitle,
            @"description": descriptionText,
        },
        @"images": @{
            @"main": @{
                @"placeholder": mainImagePlaceholderIdentifier
            },
            @"background": @{
                @"placeholder": backgroundImagePlaceholderIdentifier
            },
            @"custom": @{
                customImageIdentifier: @{
                    @"placeholder": customImagePlaceholderIdentifier
                }
            },
            @"icon": iconIdentifier
        },
        @"target": @{
            @"uri": targetURL.absoluteString,
            @"view": @{
                @"id": targetViewIdentifier,
                @"title": targetTitle
            },
            @"actions": @[targetActionIdentifier.identifierString]
        },
        @"metadata": metadata,
        @"logging": loggingData,
        @"custom": customData,
        @"children": @[
            @{
                @"id": child1ModelIdentifier,
                @"component": @{
                    @"id": child1ComponentIdentifier.identifierString,
                    @"category": @"child1Category"
                }
            },
            @{
                @"id": child2ModelIdentifier,
                @"component": @{
                    @"id": child2ComponentIdentifier.identifierString,
                    @"category": @"child2Category"
                }
            }
        ]
    };
    
    [self.builder addJSONDictionary:dictionary];
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    
    XCTAssertEqualObjects(model.componentIdentifier, componentIdentifier);
    XCTAssertEqualObjects(model.componentCategory, @"mainCategory");
    XCTAssertEqualObjects(model.title, title);
    XCTAssertEqualObjects(model.subtitle, subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, descriptionText);
    XCTAssertEqualObjects(model.mainImageData.placeholderIcon.identifier, mainImagePlaceholderIdentifier);
    XCTAssertEqualObjects(model.backgroundImageData.placeholderIcon.identifier, backgroundImagePlaceholderIdentifier);
    XCTAssertEqualObjects(model.customImageData[customImageIdentifier].placeholderIcon.identifier, customImagePlaceholderIdentifier);
    XCTAssertEqualObjects(model.icon.identifier, iconIdentifier);
    XCTAssertEqualObjects(model.target.URI, targetURL);
    XCTAssertEqualObjects(model.target.initialViewModel.navigationItem.title, targetTitle);
    XCTAssertEqual(model.target.actionIdentifiers.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.target.actionIdentifiers.firstObject, targetActionIdentifier);
    
    XCTAssertEqualObjects(model.metadata, metadata);
    XCTAssertEqualObjects(model.loggingData, loggingData);
    XCTAssertEqualObjects(model.customData, customData);
    
    id<HUBComponentModel> const childModel1 = model.children[0];
    XCTAssertEqualObjects(childModel1.identifier, child1ModelIdentifier);
    XCTAssertEqualObjects(childModel1.componentIdentifier, child1ComponentIdentifier);
    XCTAssertEqualObjects(childModel1.componentCategory, @"child1Category");
    
    id<HUBComponentModel> const childModel2 = model.children[1];
    XCTAssertEqualObjects(childModel2.identifier, child2ModelIdentifier);
    XCTAssertEqualObjects(childModel2.componentIdentifier, child2ComponentIdentifier);
    XCTAssertEqualObjects(childModel2.componentCategory, @"child2Category");
    
    // Serializing should produce an identical dictionary as was passed as JSON data
    XCTAssertEqualObjects(dictionary, [model serialize]);
}

- (void)testAddingJSONDataNotRemovingExistingData
{
    self.builder.componentNamespace = @"namespace";
    self.builder.componentName = @"name";
    self.builder.preferredIndex = @(33);
    self.builder.title = @"title";
    self.builder.subtitle = @"subtitle";
    self.builder.accessoryTitle = @"accessory title";
    self.builder.descriptionText = @"description text";
    self.builder.targetBuilder.URI = [NSURL URLWithString:@"spotify:hub:framework"];
    self.builder.loggingData = @{@"logging": @"data"};
    self.builder.customData = @{@"custom": @"data"};
    
    NSData * const data = [NSJSONSerialization dataWithJSONObject:@{} options:(NSJSONWritingOptions)0 error:nil];
    [self.builder addJSONData:data error:nil];
    
    XCTAssertEqualObjects(self.builder.componentNamespace, @"namespace");
    XCTAssertEqualObjects(self.builder.componentName, @"name");
    XCTAssertEqualObjects(self.builder.preferredIndex, @(33));
    XCTAssertEqualObjects(self.builder.title, @"title");
    XCTAssertEqualObjects(self.builder.subtitle, @"subtitle");
    XCTAssertEqualObjects(self.builder.accessoryTitle, @"accessory title");
    XCTAssertEqualObjects(self.builder.descriptionText, @"description text");
    XCTAssertEqualObjects(self.builder.targetBuilder.URI, [NSURL URLWithString:@"spotify:hub:framework"]);
    XCTAssertEqualObjects(self.builder.loggingData, @{@"logging": @"data"});
    XCTAssertEqualObjects(self.builder.customData, @{@"custom": @"data"});
}

- (void)testMetadataFromJSONAddedToExistingMetadata
{
    self.builder.metadata = @{@"meta": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"metadata": @{
            @"another": @"value"
        }
    };
    
    [self.builder addJSONDictionary:JSONDictionary];
    
    NSDictionary * const expectedMetadata = @{
        @"meta": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(self.builder.metadata, expectedMetadata);
}

- (void)testLoggingDataFromJSONAddedToExistingLoggingData
{
    self.builder.loggingData = @{@"logging": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"logging": @{
            @"another": @"value"
        }
    };
    
    [self.builder addJSONDictionary:JSONDictionary];
    
    NSDictionary * const expectedLoggingData = @{
        @"logging": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(self.builder.loggingData, expectedLoggingData);
}

- (void)testCustomDataFromJSONAddedToExistingCustomData
{
    self.builder.customData = @{@"custom": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"custom": @{
            @"another": @"value"
        }
    };
    
    [self.builder addJSONDictionary:JSONDictionary];
    
    NSDictionary * const expectedCustomData = @{
        @"custom": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(self.builder.customData, expectedCustomData);
}

- (void)testAddingNonDictionaryJSONDataReturnsError
{
    NSData * const stringData = [@"Not a dictionary" dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    const BOOL success = [self.builder addJSONData:stringData error:&error];

    XCTAssertFalse(success, @"Should not return success when failed to add JSON data");
    XCTAssertNotNil(error, @"Should set the output error parameter");
}

- (void)testAddingNonDictionaryJSONDataDoesNotCrash
{
    NSData * const arrayData = [NSJSONSerialization dataWithJSONObject:@[] options:(NSJSONWritingOptions)0 error:nil];

    const BOOL success = [self.builder addJSONData:arrayData error:nil];

    XCTAssertFalse(success, @"Should not return success when failed to add JSON data");
}

- (void)testCopying
{
    self.builder.componentNamespace = @"namespace for copying";
    self.builder.componentName = @"name for copying";
    self.builder.componentCategory = @"category for copying";
    self.builder.preferredIndex = @(33);
    self.builder.groupIdentifier = @"group identifier";
    self.builder.title = @"title";
    self.builder.subtitle = @"subtitle";
    self.builder.accessoryTitle = @"accessory title";
    self.builder.descriptionText = @"description text";
    self.builder.targetBuilder.URI = [NSURL URLWithString:@"spotify:hub:framework"];
    self.builder.loggingData = @{@"logging": @"data"};
    self.builder.metadata = @{@"meta": @"data"};
    self.builder.customData = @{@"custom": @"data"};
    
    self.builder.mainImageDataBuilder.placeholderIconIdentifier = @"mainPlaceholder";
    self.builder.backgroundImageDataBuilder.placeholderIconIdentifier = @"backgroundPlaceholder";
    
    id<HUBComponentImageDataBuilder> const customImageDataBuilder = [self.builder builderForCustomImageDataWithIdentifier:@"customImage"];
    customImageDataBuilder.placeholderIconIdentifier = @"customPlaceholder";
    
    HUBComponentModelBuilderImplementation * const builderCopy = [self.builder copy];
    
    XCTAssertEqualObjects(builderCopy.componentNamespace, @"namespace for copying");
    XCTAssertEqualObjects(builderCopy.componentName, @"name for copying");
    XCTAssertEqualObjects(builderCopy.componentCategory, @"category for copying");
    XCTAssertEqualObjects(builderCopy.preferredIndex, @(33));
    XCTAssertEqualObjects(builderCopy.groupIdentifier, @"group identifier");
    XCTAssertEqualObjects(builderCopy.title, @"title");
    XCTAssertEqualObjects(builderCopy.subtitle, @"subtitle");
    XCTAssertEqualObjects(builderCopy.accessoryTitle, @"accessory title");
    XCTAssertEqualObjects(builderCopy.descriptionText, @"description text");
    XCTAssertEqualObjects(builderCopy.targetBuilder.URI, [NSURL URLWithString:@"spotify:hub:framework"]);
    XCTAssertEqualObjects(builderCopy.loggingData, @{@"logging": @"data"});
    XCTAssertEqualObjects(builderCopy.metadata, @{@"meta": @"data"});
    XCTAssertEqualObjects(builderCopy.customData, @{@"custom": @"data"});
    
    XCTAssertNotEqual(self.builder.mainImageDataBuilder, builderCopy.mainImageDataBuilder);
    XCTAssertEqualObjects(builderCopy.mainImageDataBuilder.placeholderIconIdentifier, @"mainPlaceholder");
    
    XCTAssertNotEqual(self.builder.backgroundImageDataBuilder, builderCopy.backgroundImageDataBuilder);
    XCTAssertEqualObjects(builderCopy.backgroundImageDataBuilder.placeholderIconIdentifier, @"backgroundPlaceholder");
    
    id<HUBComponentImageDataBuilder> const copiedCustomImageDataBuilder = [builderCopy builderForCustomImageDataWithIdentifier:@"customImage"];
    XCTAssertNotEqual(customImageDataBuilder, copiedCustomImageDataBuilder);
    XCTAssertEqualObjects(copiedCustomImageDataBuilder.placeholderIconIdentifier, @"customPlaceholder");
}

- (void)testBuildersForChildrenInGroupWhenAddingChildBuilder
{
    NSString * const firstChildModelIdentifier = @"firstIdentifier";
    NSString * const secondChildModelIdentifier = @"secondIdentifier";
    NSString * const firstChildGroupIdentifier = @"firstGroup";
    NSString * const secondChildGroupIdentifier = @"secondGroup";

    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:firstChildModelIdentifier];
    childBuilder.groupIdentifier = firstChildGroupIdentifier;
    id<HUBComponentModelBuilder> const childBuilder2 = [self.builder builderForChildWithIdentifier:secondChildModelIdentifier];
    childBuilder2.groupIdentifier = secondChildGroupIdentifier;

    NSArray *buildersForFirstGroup = [self.builder buildersForChildrenInGroupWithIdentifier:firstChildGroupIdentifier];
    NSArray *buildersForSecondGroup = [self.builder buildersForChildrenInGroupWithIdentifier:secondChildGroupIdentifier];

    XCTAssertTrue(buildersForFirstGroup.count == 1);
    XCTAssertEqualObjects(buildersForFirstGroup.firstObject, childBuilder);
    XCTAssertTrue(buildersForSecondGroup.count == 1);
    XCTAssertEqualObjects(buildersForSecondGroup.firstObject, childBuilder2);
}

- (void)testBuildersForChildrenInGroupWhenRemovingChildBuilder
{
    NSString * const firstChildModelIdentifier = @"firstIdentifier";
    NSString * const secondChildModelIdentifier = @"secondIdentifier";
    NSString * const firstChildGroupIdentifier = @"firstGroup";
    NSString * const secondChildGroupIdentifier = @"secondGroup";

    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:firstChildModelIdentifier];
    childBuilder.groupIdentifier = firstChildGroupIdentifier;
    id<HUBComponentModelBuilder> const childBuilder2 = [self.builder builderForChildWithIdentifier:secondChildModelIdentifier];
    childBuilder2.groupIdentifier = secondChildGroupIdentifier;

    [self.builder removeBuilderForChildWithIdentifier:firstChildModelIdentifier];

    NSArray *buildersForFirstGroup = [self.builder buildersForChildrenInGroupWithIdentifier:firstChildGroupIdentifier];
    NSArray *buildersForSecondGroup = [self.builder buildersForChildrenInGroupWithIdentifier:secondChildGroupIdentifier];

    XCTAssertNil(buildersForFirstGroup);
    XCTAssertTrue(buildersForSecondGroup.count == 1);
    XCTAssertEqualObjects(buildersForSecondGroup.firstObject, childBuilder2);
}

- (void)testBuildersForChildrenInGroupWhenRemovingAllChildBuilders
{
    NSString * const firstChildModelIdentifier = @"firstIdentifier";
    NSString * const secondChildModelIdentifier = @"secondIdentifier";
    NSString * const firstChildGroupIdentifier = @"firstGroup";
    NSString * const secondChildGroupIdentifier = @"secondGroup";

    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:firstChildModelIdentifier];
    childBuilder.groupIdentifier = firstChildGroupIdentifier;
    id<HUBComponentModelBuilder> const childBuilder2 = [self.builder builderForChildWithIdentifier:secondChildModelIdentifier];
    childBuilder2.groupIdentifier = secondChildGroupIdentifier;

    [self.builder removeAllChildBuilders];

    NSArray *buildersInFirstGroup = [self.builder buildersForChildrenInGroupWithIdentifier:firstChildGroupIdentifier];
    NSArray *buildersInSecondGroup = [self.builder buildersForChildrenInGroupWithIdentifier:secondChildGroupIdentifier];

    XCTAssertNil(buildersInFirstGroup);
    XCTAssertNil(buildersInSecondGroup);
}

- (void)testBuildersForChildrenInGroupWhenChangingGroupIdentifierOfChild
{
    NSString * const childModelIdentifier = @"identifier";
    NSString * const firstGroupIdentifier = @"firstGroup";
    NSString * const secondGroupIdentifier = @"secondGroup";

    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildWithIdentifier:childModelIdentifier];
    childBuilder.groupIdentifier = firstGroupIdentifier;

    NSArray *buildersInFirstGroup = [self.builder buildersForChildrenInGroupWithIdentifier:firstGroupIdentifier];
    NSArray *buildersInSecondGroup = [self.builder buildersForChildrenInGroupWithIdentifier:secondGroupIdentifier];
    XCTAssertTrue(buildersInFirstGroup.count == 1);
    XCTAssertEqualObjects(buildersInFirstGroup.firstObject, childBuilder);
    XCTAssertNil(buildersInSecondGroup);

    childBuilder.groupIdentifier = secondGroupIdentifier;

    buildersInFirstGroup = [self.builder buildersForChildrenInGroupWithIdentifier:firstGroupIdentifier];
    buildersInSecondGroup = [self.builder buildersForChildrenInGroupWithIdentifier:secondGroupIdentifier];
    XCTAssertTrue(buildersInSecondGroup.count == 1);
    XCTAssertEqualObjects(buildersInSecondGroup.firstObject, childBuilder);
    XCTAssertNil(buildersInFirstGroup);
}

@end
