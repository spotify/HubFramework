#import <XCTest/XCTest.h>

#import "HUBComponentIdentifier.h"

@interface HUBComponentIdentifierTests : XCTestCase
@end

@implementation HUBComponentIdentifierTests

- (void)testPropertyAssignment
{
    HUBComponentIdentifier * const identifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];

    XCTAssertEqualObjects(identifier.componentNamespace, @"namespace");
    XCTAssertEqualObjects(identifier.componentName, @"name");
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
