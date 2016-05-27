#import <XCTest/XCTest.h>

#import "HUBJSONPath.h"
#import "HUBMutableJSONPathImplementation.h"

@interface HUBJSONPathTests : XCTestCase

@end

@implementation HUBJSONPathTests

- (void)testBoolPath
{
    id<HUBJSONBoolPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"bool"] boolPath];
    
    XCTAssertTrue([path boolFromJSONDictionary:@{@"bool": @(YES)}]);
    XCTAssertFalse([path boolFromJSONDictionary:@{@"bool": @"notABool"}]);
    XCTAssertFalse([path boolFromJSONDictionary:@{}]);
}

- (void)testUnsignedIntegerPath
{
    id<HUBJSONIntegerPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"int"] integerPath];
    
    XCTAssertEqual([path integerFromJSONDictionary:@{@"int": @(15)}], 15);
    XCTAssertEqual([path integerFromJSONDictionary:@{@"int": @(-15)}], -15);
    XCTAssertEqual([path integerFromJSONDictionary:@{@"int": @"notAnInt"}], 0);
    XCTAssertEqual([path integerFromJSONDictionary:@{}], 0);
}

- (void)testStringPath
{
    id<HUBJSONStringPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"string"] stringPath];
    
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"string": @"hello"}], @"hello");
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"string": @""}], @"");
    XCTAssertNil([path stringFromJSONDictionary:@{@"string": @(15)}]);
    XCTAssertNil([path stringFromJSONDictionary:@{}]);
}

- (void)testURLPath
{
    id<HUBJSONURLPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"url"] URLPath];
    
    NSString * const URLString = @"http://www.spotify.com";
    NSURL * const URL = [NSURL URLWithString:URLString];
    
    XCTAssertEqualObjects([path URLFromJSONDictionary:@{@"url": URLString}], URL);
    XCTAssertEqualObjects([path URLFromJSONDictionary:@{@"url": URL}], URL);
    XCTAssertNil([path URLFromJSONDictionary:@{@"url": @"é"}]);
    XCTAssertNil([path URLFromJSONDictionary:@{@"url": @(15)}]);
    XCTAssertNil([path URLFromJSONDictionary:@{}]);
}

- (void)testArrayPath
{
    id<HUBJSONStringPath> const path = [[[[HUBMutableJSONPathImplementation path] goTo:@"array"] forEach] stringPath];
    
    NSArray * const validArray = @[@"hello", @"how", @"are", @"you?"];
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{@"array": validArray}], validArray);
    
    NSArray * const arrayWithInvalidElement = @[@"hello", @(15)];
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{@"array": arrayWithInvalidElement}], @[@"hello"]);
    
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{@"array": @[]}], @[]);
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{@"array": @"notAnArray"}], @[]);
    XCTAssertEqualObjects([path valuesFromJSONDictionary:@{}], @[]);
}

- (void)testDictionaryPath
{
    id<HUBJSONDictionaryPath> const path = [[[HUBMutableJSONPathImplementation path] goTo:@"dictionary"] dictionaryPath];
    
    NSDictionary * const dictionary = @{@"hello": @"josu"};
    XCTAssertEqualObjects([path dictionaryFromJSONDictionary:@{@"dictionary": dictionary}], dictionary);
    
    XCTAssertNil([path dictionaryFromJSONDictionary:@{@"dictionary": @"notADictionary"}]);
    XCTAssertNil([path dictionaryFromJSONDictionary:@{}]);
}

- (void)testExtendedPath
{
    id<HUBJSONStringPath> const path = [[[[[[HUBMutableJSONPathImplementation path] goTo:@"dictionary"] dictionaryPath] mutableCopy] goTo:@"string"] stringPath];
    XCTAssertEqualObjects([path stringFromJSONDictionary:@{@"dictionary": @{@"string": @"hello"}}], @"hello");
}

@end
