#import <XCTest/XCTest.h>

#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentModel.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchemaImplementation.h"

@interface HUBViewModelBuilderTests : XCTestCase

@end

@implementation HUBViewModelBuilderTests

- (void)testPropertyAssignment
{
    NSString * const featureIdentifier = @"feature";
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                   defaultComponentNamespace:@"default"];
    
    XCTAssertNotNil(builder.viewIdentifier);
    XCTAssertEqualObjects(builder.featureIdentifier, featureIdentifier);
    
    builder.viewIdentifier = @"view";
    builder.featureIdentifier = @"another feature";
    builder.entityIdentifier = @"entity";
    builder.navigationBarTitle = @"nav title";
    builder.extensionURL = [NSURL URLWithString:@"www.spotify.com"];
    builder.customData = @{@"custom": @"data"};
    
    HUBViewModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects(model.identifier, builder.viewIdentifier);
    XCTAssertEqualObjects(model.featureIdentifier, builder.featureIdentifier);
    XCTAssertEqualObjects(model.entityIdentifier, builder.entityIdentifier);
    XCTAssertEqualObjects(model.navigationBarTitle, builder.navigationBarTitle);
    XCTAssertEqualObjects(model.extensionURL, builder.extensionURL);
    XCTAssertEqualObjects(model.customData, builder.customData);
}

- (void)testHeaderComponentBuilder
{
    NSString * const defaultComponentNamespace = @"default";
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:defaultComponentNamespace];
    
    XCTAssertEqualObjects(builder.headerComponentModelBuilder.modelIdentifier, @"header");
    XCTAssertEqualObjects(builder.headerComponentModelBuilder.componentNamespace, defaultComponentNamespace);
    XCTAssertNil(builder.headerComponentModelBuilder.componentName);
}

- (void)testBodyComponentBuilders
{
    NSString * const defaultComponentNamespace = @"default";
    NSString * const componentModelIdentifier = @"identifier";
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:defaultComponentNamespace];
    
    XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
    
    id<HUBComponentModelBuilder> const componentBuilder = [builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier];
    
    XCTAssertNotNil(componentBuilder);
    XCTAssertEqualObjects(componentBuilder.componentNamespace, defaultComponentNamespace);
    XCTAssertTrue([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
    XCTAssertEqual(componentBuilder,  [builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier]);
}

- (void)testRemovalOfBodyComponentBuilders
{
    NSString * const defaultComponentNamespace = @"default";
    NSString * const componentModelIdentifier = @"identifier";

    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:defaultComponentNamespace];

    XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);

    id<HUBComponentModelBuilder> const componentBuilder = [builder builderForBodyComponentModelWithIdentifier:componentModelIdentifier];

    XCTAssertNotNil(componentBuilder);
    XCTAssertEqualObjects(componentBuilder.componentNamespace, defaultComponentNamespace);
    XCTAssertTrue([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);

    [builder removeBuilderForBodyComponentModelWithIdentifier:componentModelIdentifier];

    XCTAssertFalse([builder builderExistsForBodyComponentModelWithIdentifier:componentModelIdentifier]);
}

- (void)testBodyComponentPreferredIndexRespected
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:@"default"];
    
    NSString * const componentIdentifierA = @"componentA";
    id<HUBComponentModelBuilder> const componentBuilderA = [builder builderForBodyComponentModelWithIdentifier:componentIdentifierA];
    componentBuilderA.preferredIndex = @1;
    componentBuilderA.componentName = @"component";
    
    NSString * const componentIdentifierB = @"componentB";
    id<HUBComponentModelBuilder> const componentBuilderB = [builder builderForBodyComponentModelWithIdentifier:componentIdentifierB];
    componentBuilderB.preferredIndex = @0;
    componentBuilderB.componentName = @"component";
    
    HUBViewModelImplementation * const model = [builder build];
    XCTAssertEqual(model.bodyComponentModels.count, (NSUInteger)2);
    XCTAssertEqualObjects(model.bodyComponentModels[0].identifier, componentIdentifierB);
    XCTAssertEqual(model.bodyComponentModels[0].index, (NSUInteger)0);
    XCTAssertEqualObjects(model.bodyComponentModels[1].identifier, componentIdentifierA);
    XCTAssertEqual(model.bodyComponentModels[1].index, (NSUInteger)1);
}

- (void)testBodyComponentOutOfBoundsPreferredIndexHandled
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:@"default"];
    
    NSString * const componentIdentifier = @"component";
    id<HUBComponentModelBuilder> const componentBuilder = [builder builderForBodyComponentModelWithIdentifier:componentIdentifier];
    componentBuilder.preferredIndex = @99;
    componentBuilder.componentName = @"component";
    
    HUBViewModelImplementation * const model = [builder build];
    XCTAssertEqual(model.bodyComponentModels.count, (NSUInteger)1);
    XCTAssertEqualObjects(model.bodyComponentModels[0].identifier, componentIdentifier);
    XCTAssertEqual(model.bodyComponentModels[0].index, (NSUInteger)0);
}

- (void)testFeatureIdentifierMatchingComponentTargetInitialViewModelFeatureIdentifier
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:@"default"];
    
    XCTAssertEqualObjects(builder.headerComponentModelBuilder.targetInitialViewModelBuilder.featureIdentifier, builder.featureIdentifier);
}

- (void)testAddingViewModelDictionaryJSONData
{
    NSString * const viewIdentifier = @"identifier";
    NSString * const featureIdentifier = @"feature";
    NSString * const entityIdentifier = @"entity";
    NSString * const navigationBarTitle = @"nav bar title";
    HUBComponentIdentifier * const headerComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"header" name:@"component"];
    HUBComponentIdentifier * const bodyComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"body" name:@"component"];
    NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/extension"];
    NSDictionary * const customData = @{@"custom": @"data"};
    
    NSDictionary * const dictionary = @{
        @"id": viewIdentifier,
        @"feature": featureIdentifier,
        @"entity": entityIdentifier,
        @"title": navigationBarTitle,
        @"header": @{
            @"component": headerComponentIdentifier.identifierString
        },
        @"body": @[
            @{
                @"component": bodyComponentIdentifier.identifierString
            }
        ],
        @"extension": extensionURL.absoluteString,
        @"custom": customData
    };
    
    NSString * const defaultComponentNamespace = @"namespace";
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"temp"
                                                                                                   defaultComponentNamespace:defaultComponentNamespace];
    
    HUBJSONSchemaImplementation * const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
    
    [builder addDataFromJSONDictionary:dictionary usingSchema:JSONSchema];
    HUBViewModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects(model.identifier, viewIdentifier);
    XCTAssertEqualObjects(model.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(model.entityIdentifier, entityIdentifier);
    XCTAssertEqualObjects(model.navigationBarTitle, navigationBarTitle);
    XCTAssertEqualObjects(model.headerComponentModel.componentIdentifier, headerComponentIdentifier);
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentIdentifier, bodyComponentIdentifier);
    XCTAssertEqualObjects(model.extensionURL, extensionURL);
    XCTAssertEqualObjects(model.customData, customData);
}

- (void)testAddingComponentModelArrayJSONData
{
    HUBComponentIdentifier * const firstComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"component1"];
    HUBComponentIdentifier * const lastComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"component2"];
    
    NSArray * const array = @[
        @{
            @"component": firstComponentIdentifier.identifierString
        },
        @{
            @"component": lastComponentIdentifier.identifierString
        }
    ];
    
    NSString * const defaultComponentNamespace = @"default";
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"temp"
                                                                                                   defaultComponentNamespace:defaultComponentNamespace];
    
    HUBJSONSchemaImplementation * const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
    
    [builder addDataFromJSONArray:array usingSchema:JSONSchema];
    HUBViewModelImplementation * const model = [builder build];
    
    XCTAssertEqualObjects([model.bodyComponentModels firstObject].componentIdentifier, firstComponentIdentifier);
    XCTAssertEqualObjects([model.bodyComponentModels lastObject].componentIdentifier, lastComponentIdentifier);
}

- (void)testIsEmpty
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:@"default"];
    
    XCTAssertTrue(builder.isEmpty);
}

- (void)testNotEmptyAfterAddingHeaderComponentName
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:@"default"];
    
    builder.headerComponentModelBuilder.componentName = @"header";
    
    XCTAssertFalse(builder.isEmpty);
}

- (void)testNotEmptyAfterAddingBodyComponentModel
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:@"feature"
                                                                                                   defaultComponentNamespace:@"default"];
    
    [builder builderForBodyComponentModelWithIdentifier:@"id"];
    
    XCTAssertFalse(builder.isEmpty);
}

@end
