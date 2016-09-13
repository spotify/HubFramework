#import <XCTest/XCTest.h>

#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBComponentImageDataBuilder.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBComponentTargetBuilder.h"
#import "HUBComponentTarget.h"
#import "HUBViewModel.h"
#import "HUBViewModelBuilder.h"
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

- (void)testChildTypeSameAsParent
{
    [self.builder builderForChildComponentModelWithIdentifier:@"id"];
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertEqual(model.children[0].type, model.type);
}

- (void)testChildPreferredIndexRespected
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
    
    id<HUBComponentModel> const model = [self.builder buildForIndex:0 parent:nil];
    XCTAssertEqual(model.children.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.children[0].identifier, childIdentifierB);
    XCTAssertEqual(model.children[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.children[1].identifier, childIdentifierA);
    XCTAssertEqual(model.children[1].index, (NSUInteger)1);
}

- (void)testChildOutOfBoundsPreferredIndexHandled
{
    self.builder.componentName = @"component";
    
    NSString * const childIdentifier = @"child";
    id<HUBComponentModelBuilder> const childBuilder = [self.builder builderForChildComponentModelWithIdentifier:childIdentifier];
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
    
    [self.builder builderForChildComponentModelWithIdentifier:childIdentifier].componentName = @"component";
    XCTAssertTrue([self.builder builderExistsForChildComponentModelWithIdentifier:childIdentifier]);

    NSUInteger childBuilderCountBefore = [self.builder allChildComponentModelBuilders].count;
    [self.builder removeBuilderForChildComponentModelWithIdentifier:childIdentifier];
    XCTAssertFalse([self.builder builderExistsForChildComponentModelWithIdentifier:childIdentifier]);
    XCTAssertEqual([self.builder allChildComponentModelBuilders].count, childBuilderCountBefore - 1);
}

- (void)testRemovingAllChildComponentModelBuilders
{
    self.builder.componentName = @"component";
    
    [self.builder builderForChildComponentModelWithIdentifier:@"child1"].componentName = @"component";
    [self.builder builderForChildComponentModelWithIdentifier:@"child2"].componentName = @"component";
    [self.builder builderForChildComponentModelWithIdentifier:@"child3"].componentName = @"component";
    
    XCTAssertEqual([self.builder buildForIndex:0 parent:nil].children.count, (NSUInteger)3);
    
    [self.builder removeAllChildComponentModelBuilders];
    
    XCTAssertEqual([self.builder buildForIndex:0 parent:nil].children.count, (NSUInteger)0);
}

- (void)testChildReferenceToParent
{
    id<HUBComponentModel> const parent = [self.builder buildForIndex:0 parent:nil];
    id<HUBComponentModel> const child = [self.builder buildForIndex:0 parent:parent];
    id<HUBComponentModel> const actualParent = child.parent;
    
    XCTAssertEqual(parent, actualParent);
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
                @"placeholder": mainImagePlaceholderIdentifier,
                @"style": HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleNone)
            },
            @"background": @{
                @"placeholder": backgroundImagePlaceholderIdentifier,
                @"style": HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleRectangular)
            },
            @"custom": @{
                customImageIdentifier: @{
                    @"placeholder": customImagePlaceholderIdentifier,
                    @"style": HUBComponentImageStyleStringFromStyle(HUBComponentImageStyleCircular)
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
    
    [self.builder addDataFromJSONDictionary:dictionary];
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
    XCTAssertEqualObjects(model.target.initialViewModel.navigationBarTitle, targetTitle);
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
    [self.builder addJSONData:data];
    
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
    
    [self.builder addDataFromJSONDictionary:JSONDictionary];
    
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

- (void)testAddingNonDictionaryJSONDataReturnsError
{
    NSData * const stringData = [@"Not a dictionary" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil([self.builder addJSONData:stringData]);
    
    NSData * const arrayData = [NSJSONSerialization dataWithJSONObject:@[] options:(NSJSONWritingOptions)0 error:nil];
    XCTAssertNotNil([self.builder addJSONData:arrayData]);
}

- (void)testCopying
{
    self.builder.componentNamespace = @"namespace for copying";
    self.builder.componentName = @"name for copying";
    self.builder.componentCategory = @"category for copying";
    self.builder.preferredIndex = @(33);
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

@end
