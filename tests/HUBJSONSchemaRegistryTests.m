#import <XCTest/XCTest.h>

#import "HUBJSONSchemaRegistryImplementation.h"

@interface HUBJSONSchemaRegistryTests : XCTestCase

@property (nonatomic, strong) HUBJSONSchemaRegistryImplementation *registry;

@end

@implementation HUBJSONSchemaRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.registry = [HUBJSONSchemaRegistryImplementation new];
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

@end
