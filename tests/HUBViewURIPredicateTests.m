#import <XCTest/XCTest.h>

#import "HUBViewURIPredicate.h"

@interface HUBViewURIPredicateTests : XCTestCase

@end

@implementation HUBViewURIPredicateTests

- (void)testPredicateWithViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const predicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    XCTAssertTrue([predicate evalulateViewURI:viewURI]);
    
    NSString * const subviewURIString = [NSString stringWithFormat:@"%@:subview", viewURI.absoluteString];
    NSURL * const subviewURI = [NSURL URLWithString:subviewURIString];
    XCTAssertFalse([predicate evalulateViewURI:subviewURI]);
}

- (void)testPredicateWithRootViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const predicate = [HUBViewURIPredicate predicateWithRootViewURI:viewURI];
    XCTAssertTrue([predicate evalulateViewURI:viewURI]);
    
    NSString * const subviewURIString = [NSString stringWithFormat:@"%@:subview", viewURI.absoluteString];
    NSURL * const subviewURI = [NSURL URLWithString:subviewURIString];
    XCTAssertTrue([predicate evalulateViewURI:subviewURI]);
}

- (void)testPredicateWithRootViewURIAndExcludedViewURI
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    NSString * const subviewURIStringA = [NSString stringWithFormat:@"%@:subviewA", rootViewURI.absoluteString];
    NSURL * const subviewURIA = [NSURL URLWithString:subviewURIStringA];
    
    NSString * const subviewURIStringB = [NSString stringWithFormat:@"%@:subviewB", rootViewURI.absoluteString];
    NSURL * const subviewURIB = [NSURL URLWithString:subviewURIStringB];
    
    NSSet * const excludedViewURIs = [NSSet setWithObject:subviewURIB];
    HUBViewURIPredicate * const predicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI excludedViewURIs:excludedViewURIs];
    
    XCTAssertTrue([predicate evalulateViewURI:rootViewURI]);
    XCTAssertTrue([predicate evalulateViewURI:subviewURIA]);
    XCTAssertFalse([predicate evalulateViewURI:subviewURIB]);
}

- (void)testPredicateWithPredicate
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    NSPredicate * const predicate = [NSPredicate predicateWithFormat:@"absoluteString == %@", viewURI.absoluteString];
    
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithPredicate:predicate];
    XCTAssertTrue([viewURIPredicate evalulateViewURI:viewURI]);
    
    NSString * const subviewURIString = [NSString stringWithFormat:@"%@:subview", viewURI.absoluteString];
    NSURL * const subviewURI = [NSURL URLWithString:subviewURIString];
    XCTAssertFalse([viewURIPredicate evalulateViewURI:subviewURI]);
}

- (void)testPredicateWithBlock
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBViewURIPredicate * const truePredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return YES;
    }];
    
    XCTAssertTrue([truePredicate evalulateViewURI:viewURI]);
    
    HUBViewURIPredicate * const falsePredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return NO;
    }];
    
    XCTAssertFalse([falsePredicate evalulateViewURI:viewURI]);
}

@end
