#import <XCTest/XCTest.h>

#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBComponentImageDataJSONSchemaImplementation.h"

@interface HUBComponentImageDataBuilderTests : XCTestCase

@property (nonatomic, strong) HUBComponentImageDataBuilderImplementation *builder;

@end

@implementation HUBComponentImageDataBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.builder = [HUBComponentImageDataBuilderImplementation new];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    self.builder.style = HUBComponentImageStyleCircular;
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    self.builder.iconIdentifier = @"icon";
    
    HUBComponentImageDataImplementation * const imageData = [self.builder build];
    
    XCTAssertEqual(imageData.style, self.builder.style);
    XCTAssertEqualObjects(imageData.URL, self.builder.URL);
    XCTAssertEqualObjects(imageData.iconIdentifier, self.builder.iconIdentifier);
}

- (void)testNilURLAndIconIdentifierProducingNil
{
    XCTAssertNil([self.builder build]);
}

- (void)testOnlyURLNotProducingNil
{
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    XCTAssertNotNil([self.builder build]);
}

- (void)testOnlyIconIdentifierNotProducingNil
{
    self.builder.iconIdentifier = @"icon";
    XCTAssertNotNil([self.builder build]);
}

- (void)testAddingJSONData
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://cdn.spotify.com/image"];
    NSString * const iconIdentifier = @"playlist";
    
    NSDictionary * const dictionary = @{
        @"style": @"circular",
        @"url": imageURL.absoluteString,
        @"icon": iconIdentifier
    };
    
    [self.builder addDataFromJSONDictionary:dictionary usingSchema:[HUBComponentImageDataJSONSchemaImplementation new]];
    
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleCircular);
    XCTAssertEqualObjects(self.builder.URL, imageURL);
    XCTAssertEqualObjects(self.builder.iconIdentifier, iconIdentifier);
}

- (void)testInvalidImageStyleStringProducingRectangularStyle
{
    [self.builder addDataFromJSONDictionary:@{} usingSchema:[HUBComponentImageDataJSONSchemaImplementation new]];
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleRectangular);
    
    [self.builder addDataFromJSONDictionary:@{@"style" : @"invalid"} usingSchema:[HUBComponentImageDataJSONSchemaImplementation new]];
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleRectangular);
}

- (void)testProtectionAgainstInvalidImageStyleEnumValues
{
    id<HUBComponentImageDataJSONSchema> const schema = [HUBComponentImageDataJSONSchemaImplementation new];
    schema.styleStringMap = @{@"invalid": @(99)};
    [self.builder addDataFromJSONDictionary:@{@"style" : @"invalid"} usingSchema:schema];
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleRectangular);
}

@end
