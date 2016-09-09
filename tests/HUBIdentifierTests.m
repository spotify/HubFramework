#import <XCTest/XCTest.h>

#import "HUBIdentifier.h"

@interface HUBIdentifierTests : XCTestCase
@end

@implementation HUBIdentifierTests

- (void)testPropertyAssignment
{
    HUBIdentifier * const identifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];

    XCTAssertEqualObjects(identifier.namespacePart, @"namespace");
    XCTAssertEqualObjects(identifier.namePart, @"name");
}

- (void)testComparingTwoEqualIdentifiers
{
    HUBIdentifier * const identifierA = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBIdentifier * const identifierB = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    
    XCTAssertEqualObjects(identifierA, identifierB);
}

- (void)testComparingIdentifiersWithDifferentNamespaceOrNameShouldNotBeEqual
{
    HUBIdentifier * const identifierA = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBIdentifier * const identifierB = [[HUBIdentifier alloc] initWithNamespace:@"otherNamespace" name:@"name"];
    HUBIdentifier * const identifierC = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"otherName"];

    XCTAssertNotEqualObjects(identifierA, identifierB);
    XCTAssertNotEqualObjects(identifierA, identifierC);
}

@end
