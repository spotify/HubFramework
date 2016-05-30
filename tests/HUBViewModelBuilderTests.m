#import <XCTest/XCTest.h>

#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"

@interface HUBViewModelBuilderTests : XCTestCase

@property (nonatomic, copy) NSString *featureIdentifier;
@property (nonatomic, strong) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong) HUBViewModelBuilderImplementation *builder;

@end

@implementation HUBViewModelBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.featureIdentifier = @"feature";
    self.componentDefaults = [HUBComponentDefaults defaultsForTesting];
    self.iconImageResolver = [HUBIconImageResolverMock new];
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults iconImageResolver:self.iconImageResolver];
    
    self.builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                             JSONSchema:JSONSchema
                                                                      componentDefaults:self.componentDefaults
                                                                      iconImageResolver:self.iconImageResolver];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    XCTAssertNotNil(self.builder.viewIdentifier);
    XCTAssertEqualObjects(self.builder.featureIdentifier, self.featureIdentifier);
    
    self.builder.viewIdentifier = @"view";
    self.builder.featureIdentifier = @"another feature";
    self.builder.entityIdentifier = @"entity";
    self.builder.navigationBarTitle = @"nav title";
    self.builder.extensionURL = [NSURL URLWithString:@"www.spotify.com"];
    self.builder.customData = @{@"custom": @"data"};
    
    HUBViewModelImplementation * const model = [self.builder build];
    
    XCTAssertEqualObjects(model.identifier, self.builder.viewIdentifier);
    XCTAssertEqualObjects(model.featureIdentifier, self.builder.featureIdentifier);
    XCTAssertEqualObjects(model.entityIdentifier, self.builder.entityIdentifier);
    XCTAssertEqualObjects(model.navigationBarTitle, self.builder.navigationBarTitle);
    XCTAssertEqualObjects(model.extensionURL, self.builder.extensionURL);
    XCTAssertEqualObjects(model.customData, self.builder.customData);
}

- (void)testHeaderComponentBuilder
{
    XCTAssertEqualObjects(self.builder.headerComponentModelBuilder.modelIdentifier, @"header");
    XCTAssertEqualObjects(self.builder.headerComponentModelBuilder.componentNamespace, self.componentDefaults.componentNamespace);
    XCTAssertEqualObjects(self.builder.headerComponentModelBuilder.componentName, self.componentDefaults.componentName);
    XCTAssertEqualObjects(self.builder.headerComponentModelBuilder.componentCategory, self.componentDefaults.componentCategory);
}

- (void)testHeaderComponentBuilderExists
{
    XCTAssertFalse(self.builder.headerComponentModelBuilderExists);
    self.builder.headerComponentModelBuilder.title = @"Header";
    XCTAssertTrue(self.builder.headerComponentModelBuilderExists);
}

- (void)testRemovingHeaderComponentBuilder
{
    id<HUBComponentModelBuilder> const builder = self.builder.headerComponentModelBuilder;
    builder.title = @"title";
    [self.builder removeHeaderComponentModelBuilder];
    XCTAssertNil(self.builder.headerComponentModelBuilder.title);
}

- (void)testBodyComponentBuilders
{
    NSString * const componentModelIdentifier = @"identifier";
    XCTAssertFalse([self.builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
    
    id<HUBComponentModelBuilder> const componentBuilder = [self.builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier];
    
    XCTAssertNotNil(componentBuilder);
    XCTAssertEqualObjects(componentBuilder.componentNamespace, self.componentDefaults.componentNamespace);
    XCTAssertTrue([self.builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
    XCTAssertEqual(componentBuilder,  [self.builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier]);
}

- (void)testRemovalOfBodyComponentBuilders
{
    NSString * const componentModelIdentifier = @"identifier";
    
    XCTAssertFalse([self.builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);

    id<HUBComponentModelBuilder> const componentBuilder = [self.builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier];

    XCTAssertNotNil(componentBuilder);
    XCTAssertEqualObjects(componentBuilder.componentNamespace, self.componentDefaults.componentNamespace);
    XCTAssertTrue([self.builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);

    [self.builder removeBuilderForBodyComponentModelWithIdentifier:componentModelIdentifier];

    XCTAssertFalse([self.builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
}

- (void)testRemoveAllComponentModelBuilders
{
    self.builder.headerComponentModelBuilder.title = @"Header title";
    [self.builder builderForBodyComponentModelWithIdentifier:@"body"].title = @"Body title";
    [self.builder builderForOverlayComponentModelWithIdentifier:@"overlay"].title = @"Overlay title";
    
    XCTAssertFalse(self.builder.isEmpty);
    
    [self.builder removeAllComponentModelBuilders];
    
    XCTAssertTrue(self.builder.isEmpty);
}

- (void)testBodyComponentPreferredIndexRespected
{
    NSString * const componentIdentifierA = @"componentA";
    id<HUBComponentModelBuilder> const componentBuilderA = [self.builder builderForBodyComponentModelWithIdentifier:componentIdentifierA];
    componentBuilderA.preferredIndex = @1;
    componentBuilderA.componentName = @"component";
    
    NSString * const componentIdentifierB = @"componentB";
    id<HUBComponentModelBuilder> const componentBuilderB = [self.builder builderForBodyComponentModelWithIdentifier:componentIdentifierB];
    componentBuilderB.preferredIndex = @0;
    componentBuilderB.componentName = @"component";
    
    HUBViewModelImplementation * const model = [self.builder build];
    XCTAssertEqual(model.bodyComponentModels.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.bodyComponentModels[0].identifier, componentIdentifierB);
    XCTAssertEqual(model.bodyComponentModels[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.bodyComponentModels[1].identifier, componentIdentifierA);
    XCTAssertEqual(model.bodyComponentModels[1].index, (NSUInteger)1);
}

- (void)testBodyComponentOutOfBoundsPreferredIndexHandled
{
    NSString * const componentIdentifier = @"component";
    id<HUBComponentModelBuilder> const componentBuilder = [self.builder builderForBodyComponentModelWithIdentifier:componentIdentifier];
    componentBuilder.preferredIndex = @99;
    componentBuilder.componentName = @"component";
    
    HUBViewModelImplementation * const model = [self.builder build];
    XCTAssertEqual(model.bodyComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.bodyComponentModels[0].identifier, componentIdentifier);
    XCTAssertEqual(model.bodyComponentModels[0].index, (NSUInteger)0);
}

- (void)testOverlayComponentModelBuilders
{
    NSString * const componentIdentifier = @"overlay";
    XCTAssertFalse([self.builder builderExistsForOverlayComponentModelWithIdentifier:componentIdentifier]);
    
    id<HUBComponentModelBuilder> const builder = [self.builder builderForOverlayComponentModelWithIdentifier:componentIdentifier];
    XCTAssertEqualObjects(builder.modelIdentifier, componentIdentifier);
    
    [self.builder removeBuilderForOverlayComponentModelWithIdentifier:componentIdentifier];
    XCTAssertFalse([self.builder builderExistsForOverlayComponentModelWithIdentifier:componentIdentifier]);
}

- (void)testOverlayComponentPreferredIndexRespected
{
    [self.builder builderForOverlayComponentModelWithIdentifier:@"componentA"].preferredIndex = @1;
    [self.builder builderForOverlayComponentModelWithIdentifier:@"componentB"].preferredIndex = @0;
    
    HUBViewModelImplementation * const model = [self.builder build];
    
    XCTAssertEqual(model.overlayComponentModels.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.overlayComponentModels[0].identifier, @"componentB");
    XCTAssertEqual(model.overlayComponentModels[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.overlayComponentModels[1].identifier, @"componentA");
    XCTAssertEqual(model.overlayComponentModels[1].index, (NSUInteger)1);
}

- (void)testOverlayComponentOutOfBoundsPreferredIndexHandled
{
    [self.builder builderForOverlayComponentModelWithIdentifier:@"overlay"].preferredIndex = @99;
    HUBViewModelImplementation * const model = [self.builder build];
    
    XCTAssertEqual(model.overlayComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.overlayComponentModels[0].identifier, @"overlay");
    XCTAssertEqual(model.overlayComponentModels[0].index, (NSUInteger)0);
}

- (void)testFeatureIdentifierMatchingComponentTargetInitialViewModelFeatureIdentifier
{
    XCTAssertEqualObjects(self.builder.headerComponentModelBuilder.targetInitialViewModelBuilder.featureIdentifier, self.builder.featureIdentifier);
}

- (void)testAddingViewModelDictionaryJSONDataAndModelSerialization
{
    NSString * const viewIdentifier = @"identifier";
    NSString * const featureIdentifier = @"feature";
    NSString * const entityIdentifier = @"entity";
    NSString * const navigationBarTitle = @"nav bar title";
    NSString * const headerComponentModelIdentifier = @"header model";
    HUBComponentIdentifier * const headerComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"header" name:@"component"];
    NSString * const bodyComponentModelIdentifier = @"body model";
    HUBComponentIdentifier * const bodyComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"body" name:@"component"];
    HUBComponentIdentifier * const overlayComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"overlay" name:@"component"];
    NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/extension"];
    NSDictionary * const customData = @{@"custom": @"data"};
    
    NSDictionary * const dictionary = @{
        @"id": viewIdentifier,
        @"feature": featureIdentifier,
        @"entity": entityIdentifier,
        @"title": navigationBarTitle,
        @"header": @{
            @"id": headerComponentModelIdentifier,
            @"component": @{
                @"id": headerComponentIdentifier.identifierString,
                @"category": @"headerCategory"
            }
        },
        @"body": @[
            @{
                @"id": bodyComponentModelIdentifier,
                @"component": @{
                    @"id": bodyComponentIdentifier.identifierString,
                    @"category": @"bodyCategory"
                }
            }
        ],
        @"overlays": @[
            @{
                @"id": @"overlay component",
                @"component": @{
                    @"id": overlayComponentIdentifier.identifierString,
                    @"category": @"overlayCategory"
                }
            }
        ],
        @"extension": extensionURL.absoluteString,
        @"custom": customData
    };
    
    NSData * const data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    [self.builder addJSONData:data];
    
    HUBViewModelImplementation * const model = [self.builder build];
    
    XCTAssertEqualObjects(model.identifier, viewIdentifier);
    XCTAssertEqualObjects(model.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(model.entityIdentifier, entityIdentifier);
    XCTAssertEqualObjects(model.navigationBarTitle, navigationBarTitle);
    XCTAssertEqualObjects(model.headerComponentModel.componentIdentifier, headerComponentIdentifier);
    XCTAssertEqualObjects(model.headerComponentModel.componentCategory, @"headerCategory");
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentIdentifier, bodyComponentIdentifier);
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentCategory, @"bodyCategory");
    XCTAssertEqualObjects([model.overlayComponentModels firstObject].componentIdentifier, overlayComponentIdentifier);
    XCTAssertEqualObjects([model.overlayComponentModels firstObject].componentCategory, @"overlayCategory");
    XCTAssertEqualObjects(model.extensionURL, extensionURL);
    XCTAssertEqualObjects(model.customData, customData);
    
    // Serializing should produce an identical dictionary as was passed as JSON data
    XCTAssertEqualObjects(dictionary, [model serialize]);
}

- (void)testAddingComponentModelArrayJSONData
{
    HUBComponentIdentifier * const firstComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"component1"];
    HUBComponentIdentifier * const lastComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"component2"];
    
    NSArray * const array = @[
        @{
            @"component": @{
                @"id": firstComponentIdentifier.identifierString
            }
        },
        @{
            @"component": @{
                @"id": lastComponentIdentifier.identifierString
            }
        }
    ];
    
    NSData * const data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    [self.builder addJSONData:data];
    
    HUBViewModelImplementation * const model = [self.builder build];
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentIdentifier, firstComponentIdentifier);
    XCTAssertEqualObjects([model.bodyComponentModels lastObject].componentIdentifier, lastComponentIdentifier);
}

- (void)testAddingInvalidJSONData
{
    NSData * const data = [@"Clearly not JSON" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertNotNil([self.builder addJSONData:data]);
}

- (void)testAddingJSONDataNotRemovingExistingData
{
    self.builder.viewIdentifier = @"view";
    self.builder.featureIdentifier = @"feature";
    self.builder.entityIdentifier = @"entity";
    self.builder.navigationBarTitle = @"title";
    self.builder.headerComponentModelBuilder.title = @"header title";
    self.builder.extensionURL = [NSURL URLWithString:@"http://spotify.extension.com"];
    self.builder.customData = @{@"custom": @"data"};
    [self.builder builderForBodyComponentModelWithIdentifier:@"component"].title = @"body title";
    
    NSData * const emptyJSONData = [NSJSONSerialization dataWithJSONObject:@{} options:NSJSONWritingPrettyPrinted error:nil];
    [self.builder addJSONData:emptyJSONData];
    
    XCTAssertEqualObjects(self.builder.viewIdentifier, @"view");
    XCTAssertEqualObjects(self.builder.featureIdentifier, @"feature");
    XCTAssertEqualObjects(self.builder.entityIdentifier, @"entity");
    XCTAssertEqualObjects(self.builder.navigationBarTitle, @"title");
    XCTAssertEqualObjects(self.builder.headerComponentModelBuilder.title, @"header title");
    XCTAssertEqualObjects(self.builder.extensionURL, [NSURL URLWithString:@"http://spotify.extension.com"]);
    XCTAssertEqualObjects(self.builder.customData, @{@"custom" : @"data"});
    XCTAssertTrue([self.builder builderExistsForBodyComponentModelWithIdentifier:@"component"]);
}

- (void)testCustomDataFromJSONAddedToExistingCustomData
{
    self.builder.customData = @{@"custom": @"data"};
    
    NSDictionary * const JSONDictionary = @{
        @"custom": @{
            @"another": @"value"
        }
    };
    
    NSData * const JSONData = [NSJSONSerialization dataWithJSONObject:JSONDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [self.builder addJSONData:JSONData];
    
    NSDictionary * const expectedCustomData = @{
        @"custom": @"data",
        @"another": @"value"
    };
    
    XCTAssertEqualObjects(self.builder.customData, expectedCustomData);
}

- (void)testIsEmpty
{
    XCTAssertTrue(self.builder.isEmpty);
}

- (void)testNotEmptyAfterAccessingHeaderComponentModelBuilder
{
    self.builder.headerComponentModelBuilder.title = @"title";
    XCTAssertFalse(self.builder.isEmpty);
}

- (void)testNotEmptyAfterAddingBodyComponentModel
{
    [self.builder builderForBodyComponentModelWithIdentifier:@"id"];
    XCTAssertFalse(self.builder.isEmpty);
}

- (void)testNotEmptyAfterAddingOverlayComponentModel
{
    [self.builder builderForOverlayComponentModelWithIdentifier:@"id"];
    XCTAssertFalse(self.builder.isEmpty);
}

- (void)testCopying
{
    self.builder.viewIdentifier = @"id";
    self.builder.featureIdentifier = @"feature";
    self.builder.entityIdentifier = @"entity";
    self.builder.navigationBarTitle = @"title";
    self.builder.extensionURL = [NSURL URLWithString:@"https://spotify.extension.com"];
    self.builder.customData = @{@"custom": @"data"};
    self.builder.headerComponentModelBuilder.title = @"headerTitle";
    
    id<HUBComponentModelBuilder> const bodyComponentModelBuilder = [self.builder builderForBodyComponentModelWithIdentifier:@"body"];
    bodyComponentModelBuilder.title = @"bodyTitle";
    
    HUBViewModelBuilderImplementation * const builderCopy = [self.builder copy];
    XCTAssertNotEqual(self.builder, builderCopy);
    
    XCTAssertEqualObjects(builderCopy.viewIdentifier, @"id");
    XCTAssertEqualObjects(builderCopy.featureIdentifier, @"feature");
    XCTAssertEqualObjects(builderCopy.entityIdentifier, @"entity");
    XCTAssertEqualObjects(builderCopy.navigationBarTitle, @"title");
    XCTAssertEqualObjects(builderCopy.extensionURL, [NSURL URLWithString:@"https://spotify.extension.com"]);
    XCTAssertEqualObjects(builderCopy.customData, @{@"custom": @"data"});
    
    XCTAssertNotEqual(builderCopy.headerComponentModelBuilder, self.builder.headerComponentModelBuilder);
    XCTAssertEqualObjects(builderCopy.headerComponentModelBuilder.title, @"headerTitle");
    
    id<HUBComponentModelBuilder> const copiedComponentModelBuilder = [builderCopy builderForBodyComponentModelWithIdentifier:@"body"];
    XCTAssertNotEqual(bodyComponentModelBuilder, copiedComponentModelBuilder);
    XCTAssertEqualObjects(copiedComponentModelBuilder.title, @"bodyTitle");
}

@end
