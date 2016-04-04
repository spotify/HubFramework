#import <XCTest/XCTest.h>

#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchema.h"

@interface HUBComponentImageDataBuilderTests : XCTestCase

@property (nonatomic, strong) HUBComponentImageDataBuilderImplementation *builder;
@property (nonatomic, strong) HUBJSONSchemaImplementation *schema;

@end

@implementation HUBComponentImageDataBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:@"namespace"];
    self.builder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    self.builder.style = HUBComponentImageStyleCircular;
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    self.builder.iconIdentifier = @"icon";
    
    NSString * const identifier = @"identifier";
    HUBComponentImageType const type = HUBComponentImageTypeCustom;
    
    HUBComponentImageDataImplementation * const imageData = [self.builder buildWithIdentifier:identifier type:type];
    
    XCTAssertEqual(imageData.identifier, identifier);
    XCTAssertEqual(imageData.type, type);
    XCTAssertEqual(imageData.style, self.builder.style);
    XCTAssertEqualObjects(imageData.URL, self.builder.URL);
    XCTAssertEqualObjects(imageData.iconIdentifier, self.builder.iconIdentifier);
}

- (void)testNilURLAndIconIdentifierProducingNil
{
    XCTAssertNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testOnlyURLNotProducingNil
{
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testOnlyIconIdentifierNotProducingNil
{
    self.builder.iconIdentifier = @"icon";
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
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
    
    [self.builder addDataFromJSONDictionary:dictionary];
    
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleCircular);
    XCTAssertEqualObjects(self.builder.URL, imageURL);
    XCTAssertEqualObjects(self.builder.iconIdentifier, iconIdentifier);
}

- (void)testInvalidImageStyleStringProducingRectangularStyle
{
    [self.builder addDataFromJSONDictionary:@{}];
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleRectangular);
    
    [self.builder addDataFromJSONDictionary:@{@"style" : @"invalid"}];
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleRectangular);
}

- (void)testProtectionAgainstInvalidImageStyleEnumValues
{
    self.schema.componentImageDataSchema.styleStringMap = @{@"invalid": @(99)};
    [self.builder addDataFromJSONDictionary:@{@"style" : @"invalid"}];
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleRectangular);
}

@end
