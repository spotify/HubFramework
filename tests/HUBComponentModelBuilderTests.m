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
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier featureIdentifier:featureIdentifier];
    
    XCTAssertEqualObjects(builder.modelIdentifier, modelIdentifier);
    
    builder.componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
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
    
    XCTAssertEqualObjects(model.componentIdentifier, builder.componentIdentifier);
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

- (void)testCustomImageDataBuilder
{
    HUBComponentModelBuilderImplementation * const componentModelBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"id" featureIdentifier:@"feature"];
    NSString * const customImageIdentifier = @"customImage";
    
    XCTAssertFalse([componentModelBuilder builderExistsForCustomImageDataWithIdentifier:customImageIdentifier]);
    
    id<HUBComponentImageDataBuilder> const imageDataBuilder = [componentModelBuilder builderForCustomImageDataWithIdentifier:customImageIdentifier];
    XCTAssertTrue([componentModelBuilder builderExistsForCustomImageDataWithIdentifier:customImageIdentifier]);
    imageDataBuilder.iconIdentifier = @"icon";
    
    NSString * const emptyCustomImageBuilderIdentifier = @"empty";
    [componentModelBuilder builderForCustomImageDataWithIdentifier:emptyCustomImageBuilderIdentifier];
    
    HUBComponentModelImplementation * const componentModel = [componentModelBuilder build];
    XCTAssertEqualObjects([componentModel.customImageData objectForKey:customImageIdentifier].iconIdentifier, imageDataBuilder.iconIdentifier);
    XCTAssertNil([componentModel.customImageData objectForKey:emptyCustomImageBuilderIdentifier]);
}

- (void)testTargetInitialViewModelBuilderLazyInit
{
    NSString * const featureIdentifier = @"feature";
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model" featureIdentifier:featureIdentifier];
    XCTAssertNil([builder build].targetInitialViewModel);
    
    builder.targetInitialViewModelBuilder.navigationBarTitle = @"hello";
    XCTAssertEqualObjects([builder build].targetInitialViewModel.featureIdentifier, featureIdentifier);
}

- (void)testCreatingChildComponentModelWithIdentifier
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model" featureIdentifier:@"feature"];
    
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [builder createBuilderForChildComponentModelWithIdentifier:childModelIdentifier];
    XCTAssertEqualObjects(childBuilder.modelIdentifier, childModelIdentifier);
}

- (void)testChildComponentModelBuilderReuse
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model" featureIdentifier:@"feature"];
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelAtIndex:0 reuseExisting:NO];
    
    XCTAssertEqual([builder builderForChildComponentModelAtIndex:0 reuseExisting:YES], childBuilder);
    XCTAssertNotEqual([builder builderForChildComponentModelAtIndex:0 reuseExisting:NO], childBuilder);
}

- (void)testCreatingChildComponentModelAtOutOfBoundsIndexReturningNewInstance
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model" featureIdentifier:@"feature"];
    
    id<HUBComponentModelBuilder> const childBuilder1 = [builder builderForChildComponentModelAtIndex:0 reuseExisting:YES];
    XCTAssertNotNil(childBuilder1);
    
    id<HUBComponentModelBuilder> const childBuilder2 = [builder builderForChildComponentModelAtIndex:1 reuseExisting:YES];
    XCTAssertNotNil(childBuilder2);
    
    XCTAssertNotEqual(childBuilder1, childBuilder2);
}

- (void)testChildComponentModelFeatureIdentifierSameAsParent
{
    NSString * const featureIdentifier = @"feature";
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model" featureIdentifier:featureIdentifier];
    id<HUBComponentModelBuilder> const childBuilder = [builder builderForChildComponentModelAtIndex:0 reuseExisting:NO];
    XCTAssertEqualObjects(childBuilder.targetInitialViewModelBuilder.featureIdentifier, featureIdentifier);
}

- (void)testAddingJSONData
{
    NSString * const componentIdentifierString = @"componentIdentifier";
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
    NSString * const child1ComponentIdentifier = @"child:component1";
    NSString * const child2ModelIdentifier = @"ChildComponent2";
    NSString * const child2ComponentIdentifier = @"child:component2";
    
    NSDictionary * const dictionary = @{
        @"component": componentIdentifierString,
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
                @"component": child1ComponentIdentifier
            },
            @{
                @"id": child2ModelIdentifier,
                @"component": child2ComponentIdentifier
            }
        ]
    };
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"model" featureIdentifier:@"feature"];
    [builder addDataFromJSONDictionary:dictionary usingSchema:[HUBJSONSchemaImplementation new]];
    HUBComponentModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects(model.componentIdentifier, [[HUBComponentIdentifier alloc] initWithString:componentIdentifierString]);
    XCTAssertEqualObjects(model.contentIdentifier, contentIdentifier);
    XCTAssertEqualObjects(model.title, title);
    XCTAssertEqualObjects(model.subtitle, subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, descriptionText);
    XCTAssertEqualObjects(model.mainImageData.iconIdentifier, mainImageIconIdentifier);
    XCTAssertEqualObjects(model.backgroundImageData.iconIdentifier, backgroundImageIconIdentifier);
    XCTAssertEqualObjects([model.customImageData objectForKey:customImageIdentifier].iconIdentifier, customImageIconIdentifier);
    XCTAssertEqualObjects(model.targetURL, targetURL);
    XCTAssertEqualObjects(model.targetInitialViewModel.navigationBarTitle, targetTitle);
    XCTAssertEqualObjects(model.customData, customData);
    XCTAssertEqualObjects(model.loggingData, loggingData);
    
    NSDateComponents * const expectedDateComponents = [NSDateComponents new];
    expectedDateComponents.year = 2016;
    expectedDateComponents.month = 10;
    expectedDateComponents.day = 17;
    XCTAssertEqualObjects(model.date, [[NSCalendar currentCalendar] dateFromComponents:expectedDateComponents]);
    
    id<HUBComponentModel> const childModel1 = [model.childComponentModels objectAtIndex:0];
    XCTAssertEqualObjects(childModel1.identifier, child1ModelIdentifier);
    XCTAssertEqualObjects(childModel1.componentIdentifier, [[HUBComponentIdentifier alloc] initWithString:child1ComponentIdentifier]);
    
    id<HUBComponentModel> const childModel2 = [model.childComponentModels objectAtIndex:1];
    XCTAssertEqualObjects(childModel2.identifier, child2ModelIdentifier);
    XCTAssertEqualObjects(childModel2.componentIdentifier, [[HUBComponentIdentifier alloc] initWithString:child2ComponentIdentifier]);
}

@end
