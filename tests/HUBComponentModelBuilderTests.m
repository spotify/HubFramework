#import <XCTest/XCTest.h>

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBViewModel.h"
#import "HUBViewModelBuilder.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentDefaults+Testing.h"

@interface HUBComponentModelBuilderTests : XCTestCase

@property (nonatomic, copy) NSString *modelIdentifier;
@property (nonatomic, copy) NSString *featureIdentifier;
@property (nonatomic, strong) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong) HUBComponentModelBuilderImplementation *builder;

@end

@implementation HUBComponentModelBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.modelIdentifier = @"model";
    self.featureIdentifier = @"feature";
    self.componentDefaults = [HUBComponentDefaults defaultsForTesting];
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults];
    
    self.builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:self.modelIdentifier
                                                                         featureIdentifier:self.featureIdentifier
                                                                                JSONSchema:JSONSchema
                                                                         componentDefaults:self.componentDefaults];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    XCTAssertEqualObjects(self.builder.modelIdentifier, self.modelIdentifier);
    
    self.builder.componentNamespace = @"namespace";
    self.builder.componentName = @"name";
    self.builder.contentIdentifier = @"content";
    self.builder.title = @"title";
    self.builder.subtitle = @"subtitle";
    self.builder.accessoryTitle = @"accessory";
    self.builder.descriptionText = @"description";
    self.builder.mainImageDataBuilder.iconIdentifier = @"main";
    self.builder.backgroundImageDataBuilder.iconIdentifier = @"background";
    self.builder.targetURL = [NSURL URLWithString:@"spotify:hub"];
    self.builder.customData = @{@"key": @"value"};
    self.builder.loggingData = @{@"logging": @"data"};
    self.builder.date = [NSDate date];
    
    NSUInteger const modelIndex = 5;
    HUBComponentModelImplementation * const model = [self.builder buildForIndex:modelIndex];
    
    XCTAssertEqualObjects(model.componentIdentifier.componentNamespace, @"namespace");
    XCTAssertEqualObjects(model.componentIdentifier.componentName, @"name");
    XCTAssertEqualObjects(model.contentIdentifier, self.builder.contentIdentifier);
    XCTAssertEqual(model.index, modelIndex);
    XCTAssertEqualObjects(model.title, self.builder.title);
    XCTAssertEqualObjects(model.subtitle, self.builder.subtitle);
    XCTAssertEqualObjects(model.accessoryTitle, self.builder.accessoryTitle);
    XCTAssertEqualObjects(model.descriptionText, self.builder.descriptionText);
    XCTAssertEqualObjects(model.mainImageData.iconIdentifier, self.builder.mainImageDataBuilder.iconIdentifier);
    XCTAssertEqualObjects(model.backgroundImageData.iconIdentifier, self.builder.backgroundImageDataBuilder.iconIdentifier);
    XCTAssertEqualObjects(model.targetURL, self.builder.targetURL);
    XCTAssertEqualObjects(model.customData, self.builder.customData);
    XCTAssertEqualObjects(model.loggingData, self.builder.loggingData);
    XCTAssertEqualObjects(model.date, self.builder.date);
}

- (void)testOverridingDefaultComponentNameAndNamespace
{
    NSString * const namespaceOverride = @"namespace-override";
    NSString * const nameOverride = @"name-override";
    
    self.builder.componentNamespace = namespaceOverride;
    self.builder.componentName = nameOverride;
    
    id<HUBComponentModel> const model = [self.builder buildForIndex:0];
    XCTAssertEqualObjects(model.componentIdentifier.componentNamespace, namespaceOverride);
    XCTAssertEqualObjects(model.componentIdentifier.componentName, nameOverride);
}

- (void)testDefaultImageTypes
{
    self.builder.componentName = @"component";
    self.builder.mainImageDataBuilder.iconIdentifier = @"icon";
    self.builder.backgroundImageDataBuilder.iconIdentifier = @"icon";
    HUBComponentModelImplementation * const model = [self.builder buildForIndex:0];
    
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
    imageDataBuilder.iconIdentifier = @"icon";
    
    NSString * const emptyCustomImageBuilderIdentifier = @"empty";
    [self.builder builderForCustomImageDataWithIdentifier:emptyCustomImageBuilderIdentifier];
    
    HUBComponentModelImplementation * const componentModel = [self.builder buildForIndex:0];
    id<HUBComponentImageData> const customImageData = componentModel.customImageData[customImageIdentifier];
    
    XCTAssertEqualObjects(customImageData.identifier, customImageIdentifier);
    XCTAssertEqual(customImageData.type, HUBComponentImageTypeCustom);
    XCTAssertEqualObjects(customImageData.iconIdentifier, imageDataBuilder.iconIdentifier);
    
    XCTAssertNil(componentModel.customImageData[emptyCustomImageBuilderIdentifier]);
}

- (void)testTargetInitialViewModelBuilderLazyInit
{
    self.builder.componentName = @"component";
    
    XCTAssertNil([self.builder buildForIndex:0].targetInitialViewModel);
    
    self.builder.targetInitialViewModelBuilder.navigationBarTitle = @"hello";
    XCTAssertEqualObjects([self.builder buildForIndex:0].targetInitialViewModel.featureIdentifier, self.featureIdentifier);
}

- (void)testCreatingChildComponentModel
{
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildComponentModelWithIdentifier:childModelIdentifier];
    
    XCTAssertEqualObjects(childBuilder.modelIdentifier, childModelIdentifier);
    XCTAssertTrue([self.builder builderForChildComponentModelWithIdentifier:childModelIdentifier]);
}

- (void)testChildComponentModelBuilderReuse
{
    NSString * const childModelIdentifier = @"childModel";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildComponentModelWithIdentifier:childModelIdentifier];
    
    XCTAssertEqual([self.builder builderForChildComponentModelWithIdentifier:childModelIdentifier], childBuilder);
}

- (void)testChildComponentModelFeatureIdentifierSameAsParent
{
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildComponentModelWithIdentifier:@"identifier"];
    XCTAssertEqualObjects(childBuilder.targetInitialViewModelBuilder.featureIdentifier, self.featureIdentifier);
}

- (void)testChildComponentModelPreferredIndexRespected
{
    self.builder.componentName = @"component";
    
    NSString * const childIdentifierA = @"componentA";
    id<HUBComponentModelBuilder> const childBuilderA = [self.builder builderForChildComponentModelWithIdentifier:childIdentifierA];
    childBuilderA.preferredIndex = @1;
    childBuilderA.componentName = @"component";
    
    NSString * const childIdentifierB = @"componentB";
    id<HUBComponentModelBuilder> const childBuilderB = [self.builder builderForChildComponentModelWithIdentifier:childIdentifierB];
    childBuilderB.preferredIndex = @0;
    childBuilderB.componentName = @"component";
    
    HUBComponentModelImplementation * const model = [self.builder buildForIndex:0];
    XCTAssertEqual(model.childComponentModels.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.childComponentModels[0].identifier, childIdentifierB);
    XCTAssertEqual(model.childComponentModels[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.childComponentModels[1].identifier, childIdentifierA);
    XCTAssertEqual(model.childComponentModels[1].index, (NSUInteger)1);
}

- (void)testChildComponentModelOutOfBoundsPreferredIndexHandled
{
    self.builder.componentName = @"component";
    
    NSString * const childIdentifier = @"child";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildComponentModelWithIdentifier:childIdentifier];
    childBuilder.componentName = @"component";
    childBuilder.preferredIndex = @99;
    
    HUBComponentModelImplementation * const model = [self.builder buildForIndex:0];
    XCTAssertEqual(model.childComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.childComponentModels[0].identifier, childIdentifier);
    XCTAssertEqual(model.childComponentModels[0].index, (NSUInteger)0);
}

- (void)testRemovingAllChildComponentModels
{
    self.builder.componentName = @"component";
    
    [self.builder builderForChildComponentModelWithIdentifier:@"child1"].componentName = @"component";
    [self.builder builderForChildComponentModelWithIdentifier:@"child2"].componentName = @"component";
    [self.builder builderForChildComponentModelWithIdentifier:@"child3"].componentName = @"component";
    
    XCTAssertEqual([self.builder buildForIndex:0].childComponentModels.count, (NSUInteger)3);
    
    [self.builder removeAllChildComponentModelBuilders];
    
    XCTAssertEqual([self.builder buildForIndex:0].childComponentModels.count, (NSUInteger)0);
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
    
    [self.builder addDataFromJSONDictionary:dictionary];
    HUBComponentModelImplementation * const model = [self.builder buildForIndex:0];
    
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
    NSDate * const currentDate = [NSDate date];
    
    self.builder.componentNamespace = @"namespace";
    self.builder.componentName = @"name";
    self.builder.contentIdentifier = @"content";
    self.builder.preferredIndex = @(33);
    self.builder.title = @"title";
    self.builder.subtitle = @"subtitle";
    self.builder.accessoryTitle = @"accessory title";
    self.builder.descriptionText = @"description text";
    self.builder.targetURL = [NSURL URLWithString:@"spotify:hub:framework"];
    self.builder.loggingData = @{@"logging": @"data"};
    self.builder.date = currentDate;
    self.builder.customData = @{@"custom": @"data"};
    
    [self.builder addDataFromJSONDictionary:@{}];
    
    XCTAssertEqualObjects(self.builder.componentNamespace, @"namespace");
    XCTAssertEqualObjects(self.builder.componentName, @"name");
    XCTAssertEqualObjects(self.builder.contentIdentifier, @"content");
    XCTAssertEqualObjects(self.builder.preferredIndex, @(33));
    XCTAssertEqualObjects(self.builder.title, @"title");
    XCTAssertEqualObjects(self.builder.subtitle, @"subtitle");
    XCTAssertEqualObjects(self.builder.accessoryTitle, @"accessory title");
    XCTAssertEqualObjects(self.builder.descriptionText, @"description text");
    XCTAssertEqualObjects(self.builder.targetURL, [NSURL URLWithString:@"spotify:hub:framework"]);
    XCTAssertEqualObjects(self.builder.loggingData, @{@"logging": @"data"});
    XCTAssertEqualObjects(self.builder.date, currentDate);
    XCTAssertEqualObjects(self.builder.customData, @{@"custom": @"data"});
}

- (void)testLoggingDataFromJSONAddedToExistingLoggingData
{
    self.builder.loggingData = @{@"logging": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"logging": @{
            @"another": @"value"
        }
    };
    
    [self.builder addDataFromJSONDictionary:JSONDictionary];
    
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
    
    [self.builder addDataFromJSONDictionary:JSONDictionary];
    
    NSDictionary * const expectedCustomData = @{
        @"custom": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(self.builder.customData, expectedCustomData);
}

@end
