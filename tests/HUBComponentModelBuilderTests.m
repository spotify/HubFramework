#import <XCTest/XCTest.h>

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBViewModel.h"
#import "HUBViewModelBuilder.h"

@interface HUBComponentModelBuilderTests : XCTestCase

@end

@implementation HUBComponentModelBuilderTests

- (void)testPropertyAssignment
{
    NSString * const modelIdentifier = @"model";
    NSString * const featureIdentifier = @"feature";
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier featureIdentifier:featureIdentifier];
    
    XCTAssertEqualObjects(builder.modelIdentifier, modelIdentifier);
    
    builder.componentIdentifier = @"component";
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

@end
