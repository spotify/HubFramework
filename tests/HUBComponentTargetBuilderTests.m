#import <XCTest/XCTest.h>

#import "HUBComponentTargetBuilderImplementation.h"
#import "HUBComponentTarget.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBViewModelBuilder.h"
#import "HUBViewModel.h"
#import "HUBIdentifier.h"

@interface HUBComponentTargetBuilderTests : XCTestCase

@property (nonatomic, strong) HUBComponentTargetBuilderImplementation *builder;

@end

@implementation HUBComponentTargetBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                      iconImageResolver:nil];
    
    self.builder = [[HUBComponentTargetBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                     componentDefaults:componentDefaults
                                                                     iconImageResolver:nil
                                                                     actionIdentifiers:nil];
}

#pragma mark - Tests

- (void)testEmptyBuilderStillProducingModel
{
    XCTAssertNotNil([self.builder build]);
}

- (void)testPropertyAssignmentAndCopying
{
    NSURL * const URI = [NSURL URLWithString:@"spotify:hub:framework"];
    NSString * const initialViewModelNavigationBarTitle = @"Initial nav bar title";
    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    NSDictionary * const customData = @{@"custom": @"data"};
    
    self.builder.URI = URI;
    self.builder.initialViewModelBuilder.navigationBarTitle = initialViewModelNavigationBarTitle;
    [self.builder.actionIdentifiers addObject:actionIdentifier];
    self.builder.customData = customData;
    
    id<HUBComponentTarget> const target = [self.builder build];
    
    XCTAssertEqualObjects(target.URI, URI);
    XCTAssertEqualObjects(target.initialViewModel.navigationBarTitle, initialViewModelNavigationBarTitle);
    XCTAssertEqualObjects(target.actionIdentifiers, @[actionIdentifier]);
    XCTAssertEqualObjects(target.customData, customData);
    
    HUBComponentTargetBuilderImplementation * const copiedBuilder = [self.builder copy];
    id<HUBComponentTarget> const copiedBuilderTarget = [copiedBuilder build];
    
    XCTAssertEqualObjects(copiedBuilderTarget.URI, URI);
    XCTAssertEqualObjects(copiedBuilderTarget.initialViewModel.navigationBarTitle, initialViewModelNavigationBarTitle);
    XCTAssertEqualObjects(copiedBuilderTarget.actionIdentifiers, @[actionIdentifier]);
    XCTAssertEqualObjects(copiedBuilderTarget.customData, customData);
}

- (void)testAddingActionThroughConvenienceAPI
{
    [self.builder addActionWithNamespace:@"namespace" name:@"name"];
    
    id<HUBComponentTarget> const target = [self.builder build];
    XCTAssertEqualObjects(target.actionIdentifiers, @[[[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"]]);
}

- (void)testDuplicateActionIdentifiersIgnored
{
    [self.builder.actionIdentifiers addObject:[[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"]];
    [self.builder.actionIdentifiers addObject:[[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"]];
    
    id<HUBComponentTarget> const target = [self.builder build];
    XCTAssertEqualObjects(target.actionIdentifiers, @[[[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"]]);
}

- (void)testNonNamespacedJSONActionIdentifiersIgnored
{
    NSDictionary * const dictionary = @{
        @"actions": @[
            @"valid:action",
            @"invalidAction"
        ]
    };
    
    [self.builder addDataFromJSONDictionary:dictionary];
    
    id<HUBComponentTarget> const target = [self.builder build];
    XCTAssertEqualObjects(target.actionIdentifiers, @[[[HUBIdentifier alloc] initWithNamespace:@"valid" name:@"action"]]);
}

- (void)testInitialViewModelBuilderLazyInit
{
    // Since we're not accessing .initialViewModelBuilder here, it shouldn't be created
    XCTAssertNil([self.builder build].initialViewModel);
}

- (void)testAddingJSONDataNotRemovingExistingData
{
    [self.builder addActionWithNamespace:@"code" name:@"actionA"];
    self.builder.customData = @{@"code": @"customA"};
    
    NSDictionary * const dictionary = @{
        @"actions": @[@"json:actionB"],
        @"custom": @{@"json": @"customB"}
    };
    
    [self.builder addDataFromJSONDictionary:dictionary];
    
    id<HUBComponentTarget> const target = [self.builder build];
    
    NSArray<HUBIdentifier *> * const expectedActionIdentifiers = @[
        [[HUBIdentifier alloc] initWithNamespace:@"code" name:@"actionA"],
        [[HUBIdentifier alloc] initWithNamespace:@"json" name:@"actionB"]
    ];
    
    NSDictionary * const expectedCustomData = @{
        @"code": @"customA",
        @"json": @"customB"
    };
    
    XCTAssertEqualObjects(target.actionIdentifiers, expectedActionIdentifiers);
    XCTAssertEqualObjects(target.customData, expectedCustomData);
}

@end
