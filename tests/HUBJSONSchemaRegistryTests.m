#import <XCTest/XCTest.h>

#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBIconImageResolverMock.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelJSONSchema.h"
#import "HUBMutableJSONPath.h"
#import "HUBViewModel.h"

@interface HUBJSONSchemaRegistryTests : XCTestCase

@property (nonatomic, strong) HUBJSONSchemaRegistryImplementation *registry;

@end

@implementation HUBJSONSchemaRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    
    self.registry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                         iconImageResolver:iconImageResolver];
}

#pragma mark - Tests

- (void)testRegisteringAndRetrievingCustomSchema
{
    id<HUBJSONSchema> const customSchema = [self.registry createNewSchema];
    NSString * const customSchemaIdentifier = @"custom";
    [self.registry registerCustomSchema:customSchema forIdentifier:customSchemaIdentifier];
    XCTAssertEqualObjects([self.registry customSchemaForIdentifier:customSchemaIdentifier], customSchema);
}

- (void)testRetrievingUnknownSchemaReturnsNil
{
    XCTAssertNil([self.registry customSchemaForIdentifier:@"unknown"]);
}

- (void)testRegisteringCustomSchemaWithExistingIdentifierThrows
{
    id<HUBJSONSchema> const customSchema = [self.registry createNewSchema];
    NSString * const customSchemaIdentifier = @"custom";
    [self.registry registerCustomSchema:customSchema forIdentifier:customSchemaIdentifier];
    XCTAssertThrows([self.registry registerCustomSchema:customSchema forIdentifier:customSchemaIdentifier]);
}

- (void)testCopyingSchema
{
    id<HUBJSONSchema> const originalSchema = [self.registry createNewSchema];
    originalSchema.viewModelSchema.navigationBarTitlePath = [[[originalSchema createNewPath] goTo:@"customTitle"] stringPath];
    
    NSString * const schemaIdentifier = @"custom";
    [self.registry registerCustomSchema:originalSchema forIdentifier:schemaIdentifier];
    
    id<HUBJSONSchema> const copiedSchema = [self.registry copySchemaWithIdentifier:schemaIdentifier];
    
    // Make sure the copied schema is not the same instance as the original
    XCTAssertNotEqual(originalSchema, copiedSchema);
    
    // Test schema equality by JSON parsing
    NSString * const title = @"Hub it up!";
    
    NSDictionary * const dictionary = @{
        @"customTitle": title
    };
    
    NSString * const featureIdentifier = @"feature";
    
    id<HUBViewModel> const originalViewModel = [originalSchema viewModelFromJSONDictionary:dictionary featureIdentifier:featureIdentifier];
    id<HUBViewModel> const copiedViewModel = [copiedSchema viewModelFromJSONDictionary:dictionary featureIdentifier:featureIdentifier];
    
    XCTAssertEqual(originalViewModel.navigationBarTitle, title);
    XCTAssertEqual(originalViewModel.navigationBarTitle, copiedViewModel.navigationBarTitle);
}

- (void)testCopyingUknownSchemaReturningNil
{
    XCTAssertNil([self.registry copySchemaWithIdentifier:@"unknown"]);
}

@end
