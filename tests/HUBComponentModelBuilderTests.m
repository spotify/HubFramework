#import <XCTest/XCTest.h>

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBViewModel.h"
#import "HUBViewModelBuilder.h"
#import "HUBJSONSchemaImplementation.h"

@interface HUBComponentModelBuilderTests : XCTestCase

@end

@implementation HUBComponentModelBuilderTests

- (void)testPropertyAssignment
{
    NSString * const modelIdentifier = @"model";
    NSString * const featureIdentifier = @"feature";
    NSString * const componentNamespace = @"namespace";
    NSString * const componentName = @"component";
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:componentNamespace];
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier
                                                                                                                   featureIdentifier:featureIdentifier
                                                                                                                          JSONSchema:JSONSchema
                                                                                                           defaultComponentNamespace:componentNamespace];
    
    XCTAssertEqualObjects(builder.modelIdentifier, modelIdentifier);
    
    builder.componentName = componentName;
    builder.contentIdentifier = @"content";
    builder.title = @"title";
    builder.subtitle = @"subtitle";
    builder.accessoryTitle = @"accessory";
    builder.descriptionText = @"description";
    builder.mainImageDataBuilder.iconIdentifier = @"main";
    builder.backgroundImageDataBuilder.iconIdentifier = @"background";
    builder.targetURL = [NSURL URLWithString:@"spotify:hub"];
    builder.customData = @{@"key": @"value"};
    builder.loggingData = @{@"logging": @"data"};
    builder.date = [NSDate date];
    
    NSUInteger const modelIndex = 5;
    HUBComponentModelImplementation * const model = [builder buildForIndex:modelIndex];
    HUBComponentIdentifier * const expectedComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentNamespace
                                                                                                              name:componentName];
    
    XCTAssertEqualObjects(model.componentIdentifier, expectedComponentIdentifier);
    XCTAssertEqualObjects(model.contentIdentifier, builder.contentIdentifier);
    XCTAssertEqual(model.index, modelIndex);
    XCTAssertEqualObjects(model.title, builder.title);
    XCTAssertEqualObjects(model.subtitle, builder.subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, builder.accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, builder.descriptionText);
    XCTAssertEqualObjects(model.mainImageData.iconIdentifier, builder.mainImageDataBuilder.iconIdentifier);
    XCTAssertEqualObjects(model.backgroundImageData.iconIdentifier, builder.backgroundImageDataBuilder.iconIdentifier);
    XCTAssertEqualObjects(model.targetURL, builder.targetURL);
    XCTAssertEqualObjects(model.customData, builder.customData);
    XCTAssertEqualObjects(model.loggingData, builder.loggingData);
    XCTAssertEqualObjects(model.date, builder.date);
}

- (void)testOverridingDefaultComponentNamespace
{
    NSString * const namespaceOverride = @"namespace-override";
    
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentNamespace = namespaceOverride;
    builder.componentName = @"component";
    
    XCTAssertEqualObjects([builder buildForIndex:0].componentIdentifier.componentNamespace, namespaceOverride);
}

- (void)testMissingComponentNameProducingNilInstance
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    XCTAssertNil([builder buildForIndex:0]);
}

- (void)testDefaultImageTypes
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    builder.mainImageDataBuilder.iconIdentifier = @"icon";
    builder.backgroundImageDataBuilder.iconIdentifier = @"icon";
    HUBComponentModelImplementation * const model = [builder buildForIndex:0];
    
    XCTAssertEqual(model.mainImageData.type, HUBComponentImageTypeMain);
    XCTAssertEqual(model.backgroundImageData.type, HUBComponentImageTypeBackground);
}

- (void)testImageConvenienceAPIs
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    builder.mainImageURL = [NSURL URLWithString:@"https://spotify.mainImage"];
    builder.mainImage = [UIImage new];
    builder.backgroundImageURL = [NSURL URLWithString:@"https://spotify.mainImage"];
    builder.backgroundImage = [UIImage new];
    
    XCTAssertEqualObjects(builder.mainImageDataBuilder.URL, builder.mainImageURL);
    XCTAssertEqual(builder.mainImageDataBuilder.localImage, builder.mainImage);
    XCTAssertEqualObjects(builder.backgroundImageDataBuilder.URL, builder.backgroundImageURL);
    XCTAssertEqual(builder.backgroundImageDataBuilder.localImage, builder.backgroundImage);
}

- (void)testCustomImageDataBuilder
{
    HUBComponentModelBuilderImplementation * const componentModelBuilder = [self createBuilderWithModelIdentifier:@"model"
                                                                                                featureIdentifier:@"feature"
                                                                                        defaultComponentNamespace:@"namespace"];
    
    componentModelBuilder.componentName = @"component";
    
    NSString * const customImageIdentifier = @"customImage";
    
    XCTAssertFalse([componentModelBuilder builderExistsForCustomImageDataWithIdentifier:customImageIdentifier]);
    
    id<HUBComponentImageDataBuilder> const imageDataBuilder = [componentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier];
    XCTAssertTrue([componentModelBuilder builderExistsForCustomImageDataWithIdentifier:customImageIdentifier]);
    imageDataBuilder.iconIdentifier = @"icon";
    
    NSString * const emptyCustomImageBuilderIdentifier = @"empty";
    [componentModelBuilder builderForCustomImageDataWithIdentifier:emptyCustomImageBuilderIdentifier];
    
    HUBComponentModelImplementation * const componentModel = [componentModelBuilder buildForIndex:0];
    id<HUBComponentImageData> const customImageData = componentModel.customImageData[customImageIdentifier];
    
    XCTAssertEqualObjects(customImageData.identifier, customImageIdentifier);
    XCTAssertEqual(customImageData.type, HUBComponentImageTypeCustom);
    XCTAssertEqualObjects(customImageData.iconIdentifier, imageDataBuilder.iconIdentifier);
    
    XCTAssertNil(componentModel.customImageData[emptyCustomImageBuilderIdentifier]);
}

- (void)testTargetInitialViewModelBuilderLazyInit
{
    NSString * const featureIdentifier = @"feature";
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:featureIdentifier
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    
    XCTAssertNil([builder buildForIndex:0].targetInitialViewModel);
    
    builder.targetInitialViewModelBuilder.navigationBarTitle = @"hello";
    XCTAssertEqualObjects([builder buildForIndex:0].targetInitialViewModel.featureIdentifier, featureIdentifier);
}

- (void)testCreatingChildComponentModel
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:childModelIdentifier];
    
    XCTAssertEqualObjects(childBuilder.modelIdentifier, childModelIdentifier);
    XCTAssertTrue([builder builderForChildComponentModelWithIdentifier:childModelIdentifier]);
}

- (void)testChildComponentModelBuilderReuse
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:childModelIdentifier];
    
    XCTAssertEqual([builder builderForChildComponentModelWithIdentifier:childModelIdentifier], childBuilder);
}

- (void)testChildComponentModelFeatureIdentifierSameAsParent
{
    NSString * const featureIdentifier = @"feature";
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:featureIdentifier
                                                                          defaultComponentNamespace:@"namespace"];
    
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:@"identifier"];
    XCTAssertEqualObjects(childBuilder.targetInitialViewModelBuilder.featureIdentifier, featureIdentifier);
}

- (void)testChildComponentModelPreferredIndexRespected
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    
    NSString * const childIdentifierA = @"componentA";
    id<HUBComponentModelBuilder> const childBuilderA = [builder builderForChildComponentModelWithIdentifier:childIdentifierA];
    childBuilderA.preferredIndex = @1;
    childBuilderA.componentName = @"component";
    
    NSString * const childIdentifierB = @"componentB";
    id<HUBComponentModelBuilder> const childBuilderB = [builder builderForChildComponentModelWithIdentifier:childIdentifierB];
    childBuilderB.preferredIndex = @0;
    childBuilderB.componentName = @"component";
    
    HUBComponentModelImplementation * const model = [builder buildForIndex:0];
    XCTAssertEqual(model.childComponentModels.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.childComponentModels[0].identifier, childIdentifierB);
    XCTAssertEqual(model.childComponentModels[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.childComponentModels[1].identifier, childIdentifierA);
    XCTAssertEqual(model.childComponentModels[1].index, (NSUInteger)1);
}

- (void)testChildComponentModelOutOfBoundsPreferredIndexHandled
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    
    NSString * const childIdentifier = @"child";
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:childIdentifier];
    childBuilder.componentName = @"component";
    childBuilder.preferredIndex = @99;
    
    HUBComponentModelImplementation * const model = [builder buildForIndex:0];
    XCTAssertEqual(model.childComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.childComponentModels[0].identifier, childIdentifier);
    XCTAssertEqual(model.childComponentModels[0].index, (NSUInteger)0);
}

- (void)testRemovingAllChildComponentModels
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    
    [builder builderForChildComponentModelWithIdentifier:@"child1"].componentName = @"component";
    [builder builderForChildComponentModelWithIdentifier:@"child2"].componentName = @"component";
    [builder builderForChildComponentModelWithIdentifier:@"child3"].componentName = @"component";
    
    XCTAssertEqual([builder buildForIndex:0].childComponentModels.count, (NSUInteger)3);
    
    [builder removeAllChildComponentModelBuilders];
    
    XCTAssertEqual([builder buildForIndex:0].childComponentModels.count, (NSUInteger)0);
}

- (void)testAddingJSONDataAndModelSerialization
{
    NSString * const featureIdentifier = @"feature";
    
    NSString * const modelIdentifier = @"model";
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"component"];
    NSString * const contentIdentifier = @"contentIdentifier";
    NSString * const title = @"A title";
    NSString * const subtitle = @"A subtitle";
    NSString * const accessoryTitle = @"An accessory title";
    NSString * const descriptionText = @"A description text";
    NSString * const mainImageIconIdentifier = @"mainIcon";
    NSString * const backgroundImageIconIdentifier = @"backgroundIcon";
    NSString * const customImageIdentifier = @"hologram";
    NSString * const customImageIconIdentifier = @"hologramIcon";
    NSURL * const targetURL = [NSURL URLWithString:@"spotify:hub:target"];
    NSString * const targetTitle = @"Target title";
    NSString * const targetViewIdentifier = @"identifier";
    NSDictionary * const customData = @{@"custom": @"data"};
    NSDictionary * const loggingData = @{@"logging": @"data"};
    NSString * const child1ModelIdentifier = @"ChildComponent1";
    HUBComponentIdentifier * const child1ComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"child" name:@"component1"];
    NSString * const child2ModelIdentifier = @"ChildComponent2";
    HUBComponentIdentifier * const child2ComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"child" name:@"component2"];
    
    NSDictionary * const dictionary = @{
        @"id": modelIdentifier,
        @"component": componentIdentifier.identifierString,
        @"contentId": contentIdentifier,
        @"title": title,
        @"subtitle": subtitle,
        @"accessoryTitle": accessoryTitle,
        @"description": descriptionText,
        @"images": @{
            @"main": @{
                @"icon": mainImageIconIdentifier,
                @"style": HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleNone)
            },
            @"background": @{
                @"icon": backgroundImageIconIdentifier,
                @"style": HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleRectangular)
            },
            @"custom": @{
                customImageIdentifier: @{
                    @"icon": customImageIconIdentifier,
                    @"style": HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleCircular)
                }
            }
        },
        @"target": @{
            @"url": targetURL.absoluteString,
            @"view": @{
                @"id": targetViewIdentifier,
                @"feature": featureIdentifier,
                @"title": targetTitle
            }
        },
        @"custom": customData,
        @"logging": loggingData,
        @"date": @"2016-10-17",
        @"children": @[
            @{
                @"id": child1ModelIdentifier,
                @"component": child1ComponentIdentifier.identifierString
            },
            @{
                @"id": child2ModelIdentifier,
                @"component": child2ComponentIdentifier.identifierString
            }
        ]
    };
    
    NSString * const defaultComponentNamespace = @"namespace";
    
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:modelIdentifier
                                                                                  featureIdentifier:featureIdentifier
                                                                          defaultComponentNamespace:defaultComponentNamespace];
    
    [builder addDataFromJSONDictionary:dictionary];
    HUBComponentModelImplementation * const model = [builder buildForIndex:0];
    
    XCTAssertEqualObjects(model.componentIdentifier, componentIdentifier);
    XCTAssertEqualObjects(model.contentIdentifier, contentIdentifier);
    XCTAssertEqualObjects(model.title, title);
    XCTAssertEqualObjects(model.subtitle, subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, descriptionText);
    XCTAssertEqualObjects(model.mainImageData.iconIdentifier, mainImageIconIdentifier);
    XCTAssertEqualObjects(model.backgroundImageData.iconIdentifier, backgroundImageIconIdentifier);
    XCTAssertEqualObjects(model.customImageData[customImageIdentifier].iconIdentifier, customImageIconIdentifier);
    XCTAssertEqualObjects(model.targetURL, targetURL);
    XCTAssertEqualObjects(model.targetInitialViewModel.navigationBarTitle, targetTitle);
    XCTAssertEqualObjects(model.customData, customData);
    XCTAssertEqualObjects(model.loggingData, loggingData);
    
    NSDateComponents * const expectedDateComponents = [NSDateComponents new];
    expectedDateComponents.year = 2016;
    expectedDateComponents.month = 10;
    expectedDateComponents.day = 17;
    XCTAssertEqualObjects(model.date, [[NSCalendar currentCalendar] dateFromComponents:expectedDateComponents]);
    
    id<HUBComponentModel> const childModel1 = model.childComponentModels[0];
    XCTAssertEqualObjects(childModel1.identifier, child1ModelIdentifier);
    XCTAssertEqualObjects(childModel1.componentIdentifier, child1ComponentIdentifier);
    
    id<HUBComponentModel> const childModel2 = model.childComponentModels[1];
    XCTAssertEqualObjects(childModel2.identifier, child2ModelIdentifier);
    XCTAssertEqualObjects(childModel2.componentIdentifier, child2ComponentIdentifier);
    
    // Serializing should produce an identical dictionary as was passed as JSON data
    XCTAssertEqualObjects(dictionary, [model serialize]);
}

- (void)testAddingJSONDataNotRemovingExistingData
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"default"];
    
    NSDate * const currentDate = [NSDate date];
    
    builder.componentNamespace = @"namespace";
    builder.componentName = @"name";
    builder.contentIdentifier = @"content";
    builder.preferredIndex = @(33);
    builder.title = @"title";
    builder.subtitle = @"subtitle";
    builder.accessoryTitle = @"accessory title";
    builder.descriptionText = @"description text";
    builder.targetURL = [NSURL URLWithString:@"spotify:hub:framework"];
    builder.loggingData = @{@"logging": @"data"};
    builder.date = currentDate;
    builder.customData = @{@"custom": @"data"};
    
    [builder addDataFromJSONDictionary:@{}];
    
    XCTAssertEqualObjects(builder.componentNamespace, @"namespace");
    XCTAssertEqualObjects(builder.componentName, @"name");
    XCTAssertEqualObjects(builder.contentIdentifier, @"content");
    XCTAssertEqualObjects(builder.preferredIndex, @(33));
    XCTAssertEqualObjects(builder.title, @"title");
    XCTAssertEqualObjects(builder.subtitle, @"subtitle");
    XCTAssertEqualObjects(builder.accessoryTitle, @"accessory title");
    XCTAssertEqualObjects(builder.descriptionText, @"description text");
    XCTAssertEqualObjects(builder.targetURL, [NSURL URLWithString:@"spotify:hub:framework"]);
    XCTAssertEqualObjects(builder.loggingData, @{@"logging": @"data"});
    XCTAssertEqualObjects(builder.date, currentDate);
    XCTAssertEqualObjects(builder.customData, @{@"custom": @"data"});
}

- (void)testLoggingDataFromJSONAddedToExistingLoggingData
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"default"];
    
    builder.loggingData = @{@"logging": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"logging": @{
            @"another": @"value"
        }
    };
    
    [builder addDataFromJSONDictionary:JSONDictionary];
    
    NSDictionary * const expectedLoggingData = @{
        @"logging": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(builder.loggingData, expectedLoggingData);
}

- (void)testCustomDataFromJSONAddedToExistingCustomData
{
    HUBComponentModelBuilderImplementation * const builder = [self createBuilderWithModelIdentifier:@"model"
                                                                                  featureIdentifier:@"feature"
                                                                          defaultComponentNamespace:@"default"];
    
    builder.customData = @{@"custom": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"custom": @{
            @"another": @"value"
        }
    };
    
    [builder addDataFromJSONDictionary:JSONDictionary];
    
    NSDictionary * const expectedCustomData = @{
        @"custom": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(builder.customData, expectedCustomData);
}

#pragma mark - Utilities

- (HUBComponentModelBuilderImplementation *)createBuilderWithModelIdentifier:(NSString *)modelIdentifier
                                                           featureIdentifier:(NSString *)featureIdentifier
                                                   defaultComponentNamespace:(NSString *)defaultComponentNamespace
{
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
    
    return [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier
                                                                 featureIdentifier:featureIdentifier
                                                                        JSONSchema:JSONSchema
                                                         defaultComponentNamespace:defaultComponentNamespace];
}

@end
