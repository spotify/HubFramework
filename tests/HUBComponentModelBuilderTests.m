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
        @"date": @"2016-10-17"
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
}

@end
