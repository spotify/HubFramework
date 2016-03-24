#import <XCTest/XCTest.h>

#import "HUBJSONPath.h"
#import "HUBMutableJSONPathImplementation.h"

@interface HUBMutableJSONPathTests : XCTestCase

@end

@implementation HUBMutableJSONPathTests

- (void)testGoTo
{
    id<HUBJSONStringPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"string"] stringPath];
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"string": @"hello"}], @"hello");
}

- (void)testForEach
{
    id<HUBJSONStringPath> const path = [[[[[HUBMutableJSONPathImplementation path] goTo:@"array"] forEach] goTo:@"title"] stringPath];
    NSArray * const dictionaryArray = @[@{@"title": @"one"}, @{@"title": @"two"}];
    NSArray * const expectedOutputArray = @[@"one", @"two"];
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{@"array": dictionaryArray}], expectedOutputArray);
}

- (void)testRunBlock
{
    id<HUBJSONStringPath> const path = [[[[HUBMutableJSONPathImplementation path] goTo:@"string"] runBlock:^id(id input) {
        return @"blockString";
    }] stringPath];
    
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"string": @"nonBlockString"}], @"blockString");
    XCTAssertNil([path stringFromJSONDictionary:@{}]);
}

- (void)testRunBlockTypeSafety
{
    id<HUBJSONStringPath> const pathWithInvalidBlockReturn = [[[[HUBMutableJSONPathImplementation path] goTo:@"string"] runBlock:^id(id input) {
        return @{};
    }] stringPath];
    
    XCTAssertNil([pathWithInvalidBlockReturn stringFromJSONDictionary:@{@"string": @"nonBlockString"}]);
    
    id<HUBJSONStringPath> const extendedPath = [[[[[[HUBMutableJSONPathImplementation path] goTo:@"string"] stringPath] mutableCopy] runBlock:^id(id input) {
        // We're assuming this is a string here, so the preceeding nodes should protect this block
        return [input stringByAppendingString:@"append"];
    }] stringPath];
    
    XCTAssertNil([extendedPath stringFromJSONDictionary:@{@"string": @(15)}]);
}

- (void)testCopying
{
    id<HUBMutableJSONPath> const original = [[HUBMutableJSONPathImplementation path] goTo:@"key"];
    id<HUBJSONPath> const copy = [original copy];
    id<HUBMutableJSONPath> const mutableCopy = [copy mutableCopy];
    id<HUBJSONStringPath> const finalPath = [mutableCopy stringPath];
    
    NSDictionary * const dictionary = @{
        @"key": @"value"
    };
    
    XCTAssertEqualObjects([finalPath stringFromJSONDictionary:dictionary], @"value");
}

@end
