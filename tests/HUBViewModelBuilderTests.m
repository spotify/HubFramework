#import <XCTest/XCTest.h>

#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentDefaults+Testing.h"

@interface HUBViewModelBuilderTests : XCTestCase

@property (nonatomic, copy) NSString *featureIdentifier;
@property (nonatomic, strong) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong) HUBViewModelBuilderImplementation *builder;

@end

@implementation HUBViewModelBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.featureIdentifier = @"feature";
    self.componentDefaults = [HUBComponentDefaults defaultsForTesting];
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults];
    
    self.builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                             JSONSchema:JSONSchema
                                                                      componentDefaults:self.componentDefaults];
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
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:self.componentDefaults];

    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                                  JSONSchema:JSONSchema
                                                                                                           componentDefaults:self.componentDefaults];

    XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);

    id<HUBComponentModelBuilder> const componentBuilder = [builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier];

    XCTAssertNotNil(componentBuilder);
    XCTAssertEqualObjects(componentBuilder.componentNamespace, self.componentDefaults.componentNamespace);
    XCTAssertTrue([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);

    [builder removeBuilderForBodyComponentModelWithIdentifier:componentModelIdentifier];

    XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
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

@end
