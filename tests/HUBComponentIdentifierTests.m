#import <XCTest/XCTest.h>

#import "HUBComponentIdentifier.h"


@interface HUBComponentIdentifierTests : XCTestCase
@end

@implementation HUBComponentIdentifierTests

- (void)testCreateWithNamespaceAndName
{
    HUBComponentIdentifier * const identifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];

    XCTAssertEqualObjects(identifier.componentNamespace, @"namespace");
    XCTAssertEqualObjects(identifier.componentName, @"name");
}

- (void)testCreateWithValidNamespacedString
{
    HUBComponentIdentifier * const identifier = [[HUBComponentIdentifier alloc] initWithString:@"namespace:name"];

    XCTAssertEqualObjects(identifier.componentNamespace, @"namespace");
    XCTAssertEqualObjects(identifier.componentName, @"name");
}

- (void)testCreateWithValidNonNamespacedString
{
    HUBComponentIdentifier * const identifier = [[HUBComponentIdentifier alloc] initWithString:@"name"];
    XCTAssertEqualObjects(identifier.componentName, @"name");
}

- (void)testCreateWithStringWithExcessStringComponents
{
    HUBComponentIdentifier *identifier = [[HUBComponentIdentifier alloc] initWithString:@"namespace:name:something"];
    
    XCTAssertEqualObjects(identifier.componentNamespace, @"namespace");
    XCTAssertEqualObjects(identifier.componentName, @"name");
}

- (void)testCreateWithEmptyStringReturnsNil
{
    HUBComponentIdentifier *identifier = [[HUBComponentIdentifier alloc] initWithString:@""];
    XCTAssertNil(identifier);
}

- (void)testComparingTwoEqualIdentifiers
{
    HUBComponentIdentifier *identifierA = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                       name:@"name"];
    HUBComponentIdentifier *identifierB = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                       name:@"name"];

    XCTAssertEqualObjects(identifierA, identifierB);
}

- (void)testComparingIdentifiersWithDifferentNamespaceOrNameShouldNotBeEqual
{
    HUBComponentIdentifier *identifierA = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                       name:@"name"];
    HUBComponentIdentifier *identifierB = [[HUBComponentIdentifier alloc] initWithNamespace:@"otherNamespace"
                                                                                       name:@"name"];
    HUBComponentIdentifier *identifierC = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                       name:@"otherName"];

    XCTAssertNotEqualObjects(identifierA, identifierB);
    XCTAssertNotEqualObjects(identifierA, identifierC);
}

@end
