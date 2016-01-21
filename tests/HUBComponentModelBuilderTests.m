#import <XCTest/XCTest.h>

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentImageDataImplementation.h"

@interface HUBComponentModelBuilderTests : XCTestCase

@end

@implementation HUBComponentModelBuilderTests

- (void)testPropertyAssignment
{
    NSString * const modelIdentifier = @"model";
    NSString * const componentIdentifier = @"component";
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier
                                                                                                                 componentIdentifier:componentIdentifier];
    
    XCTAssertEqualObjects(builder.modelIdentifier, modelIdentifier);
    XCTAssertEqualObjects(builder.componentIdentifier, componentIdentifier);
    
    builder.contentIdentifier = @"content";
    builder.title = @"title";
    builder.subtitle = @"subtitle";
    builder.accessoryTitle = @"accessory";
    builder.descriptionText = @"description";
    builder.imageData.style = HUBComponentImageStyleCircular;
    builder.imageData.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    builder.imageData.iconIdentifier = @"icon";
    builder.targetURL = [NSURL URLWithString:@"spotify:hub"];
    builder.customData = @{@"key": @"value"};
    builder.loggingData = @{@"logging": @"data"};
    builder.date = [NSDate date];
    
    HUBComponentModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects(model.contentIdentifier, builder.contentIdentifier);
    XCTAssertEqualObjects(model.title, builder.title);
    XCTAssertEqualObjects(model.subtitle, builder.subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, builder.accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, builder.descriptionText);
    XCTAssertEqual(model.imageData.style, builder.imageData.style);
    XCTAssertEqualObjects(model.imageData.URL, builder.imageData.URL);
    XCTAssertEqualObjects(model.imageData.iconIdentifier, builder.imageData.iconIdentifier);
    XCTAssertEqualObjects(model.customData, builder.customData);
    XCTAssertEqualObjects(model.loggingData, builder.loggingData);
    XCTAssertEqualObjects(model.date, builder.date);
}

@end
