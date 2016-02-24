#import <XCTest/XCTest.h>

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentImageData.h"
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
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier
                                                                                                                   featureIdentifier:featureIdentifier
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
    
    HUBComponentModelImplementation * const model = [builder build];
    HUBComponentIdentifier * const expectedComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentNamespace
                                                                                                              name:componentName];
    
    XCTAssertEqualObjects(model.componentIdentifier, expectedComponentIdentifier);
    XCTAssertEqualObjects(model.contentIdentifier, builder.contentIdentifier);
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
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    builder.componentNamespace = namespaceOverride;
    builder.componentName = @"component";
    
    XCTAssertEqualObjects([builder build].componentIdentifier.componentNamespace, namespaceOverride);
}

- (void)testMissingComponentNameProducingNilInstance
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    XCTAssertNil([builder build]);
}

- (void)testDefaultImageTypes
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    builder.mainImageDataBuilder.iconIdentifier = @"icon";
    builder.backgroundImageDataBuilder.iconIdentifier = @"icon";
    HUBComponentModelImplementation * const model = [builder build];
    
    XCTAssertEqual(model.mainImageData.type, HUBComponentImageTypeMain);
    XCTAssertEqual(model.backgroundImageData.type, HUBComponentImageTypeBackground);
}

- (void)testCustomImageDataBuilder
{
    HUBComponentModelBuilderImplementation * const componentModelBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"id"
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
    
    HUBComponentModelImplementation * const componentModel = [componentModelBuilder build];
    id<HUBComponentImageData> const customImageData = componentModel.customImageData[customImageIdentifier];
    
    XCTAssertEqualObjects(customImageData.identifier, customImageIdentifier);
    XCTAssertEqual(customImageData.type, HUBComponentImageTypeCustom);
    XCTAssertEqualObjects(customImageData.iconIdentifier, imageDataBuilder.iconIdentifier);
    
    XCTAssertNil(componentModel.customImageData[emptyCustomImageBuilderIdentifier]);
}

- (void)testTargetInitialViewModelBuilderLazyInit
{
    NSString * const featureIdentifier = @"feature";
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:featureIdentifier
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    
    XCTAssertNil([builder build].targetInitialViewModel);
    
    builder.targetInitialViewModelBuilder.navigationBarTitle = @"hello";
    XCTAssertEqualObjects([builder build].targetInitialViewModel.featureIdentifier, featureIdentifier);
}

- (void)testCreatingChildComponentModel
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:childModelIdentifier];
    
    XCTAssertEqualObjects(childBuilder.modelIdentifier, childModelIdentifier);
    XCTAssertTrue([builder builderForChildComponentModelWithIdentifier:childModelIdentifier]);
}

- (void)testChildComponentModelBuilderReuse
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:childModelIdentifier];
    
    XCTAssertEqual([builder builderForChildComponentModelWithIdentifier:childModelIdentifier], childBuilder);
}

- (void)testChildComponentModelFeatureIdentifierSameAsParent
{
    NSString * const featureIdentifier = @"feature";
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:featureIdentifier
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:@"identifier"];
    XCTAssertEqualObjects(childBuilder.targetInitialViewModelBuilder.featureIdentifier, featureIdentifier);
}

- (void)testChildComponentModelPreferredIndexRespected
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
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
    
    HUBComponentModelImplementation * const model = [builder build];
    XCTAssertEqual(model.childComponentModels.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.childComponentModels[0].identifier, childIdentifierB);
    XCTAssertEqualObjects(model.childComponentModels[1].identifier, childIdentifierA);
}

- (void)testChildComponentModelOutOfBoundsPreferredIndexHandled
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    builder.componentName = @"component";
    
    NSString * const childIdentifier = @"child";
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelWithIdentifier:childIdentifier];
    childBuilder.componentName = @"component";
    childBuilder.preferredIndex = @99;
    
    HUBComponentModelImplementation * const model = [builder build];
    XCTAssertEqual(model.childComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.childComponentModels[0].identifier, childIdentifier);
}

- (void)testAddingJSONData
{
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
    NSDictionary * const customData = @{@"custom": @"data"};
    NSDictionary * const loggingData = @{@"logging": @"data"};
    NSString * const child1ModelIdentifier = @"ChildComponent1";
    HUBComponentIdentifier * const child1ComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"child" name:@"component1"];
    NSString * const child2ModelIdentifier = @"ChildComponent2";
    HUBComponentIdentifier * const child2ComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"child" name:@"component2"];
    
    NSDictionary * const dictionary = @{
        @"component": componentIdentifier.identifierString,
        @"contentId": contentIdentifier,
        @"title": title,
        @"subtitle": subtitle,
        @"accessoryTitle": accessoryTitle,
        @"description": descriptionText,
        @"images": @{
            @"main": @{
                @"icon": mainImageIconIdentifier
            },
            @"background": @{
                @"icon": backgroundImageIconIdentifier
            },
            @"custom": @{
                customImageIdentifier: @{
                    @"icon": customImageIconIdentifier
                }
            }
        },
        @"target": @{
            @"url": targetURL.absoluteString,
            @"view": @{
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
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model"
                                                                                                                   featureIdentifier:@"feature"
                                                                                                           defaultComponentNamespace:@"namespace"];
    
    [builder addDataFromJSONDictionary:dictionary usingSchema:[HUBJSONSchemaImplementation new]];
    HUBComponentModelImplementation * const model = [builder build];
    
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
}

@end
