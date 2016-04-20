#import <XCTest/XCTest.h>

#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchema.h"
#import "HUBComponentDefaults+Testing.h"

@interface HUBComponentImageDataBuilderTests : XCTestCase

@property (nonatomic, strong) HUBComponentImageDataBuilderImplementation *builder;
@property (nonatomic, strong) HUBJSONSchemaImplementation *schema;

@end

@implementation HUBComponentImageDataBuilderTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults];
    self.builder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema];
}

#pragma mark - Tests

- (void)testPropertyAssignment
{
    self.builder.style = HUBComponentImageStyleCircular;
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    self.builder.localImage = [UIImage new];
    self.builder.placeholderIdentifier = @"placeholder";
    
    NSString * const identifier = @"identifier";
    HUBComponentImageType const type = HUBComponentImageTypeCustom;
    
    HUBComponentImageDataImplementation * const imageData = [self.builder buildWithIdentifier:identifier type:type];
    
    XCTAssertEqual(imageData.identifier, identifier);
    XCTAssertEqual(imageData.type, type);
    XCTAssertEqual(imageData.style, self.builder.style);
    XCTAssertEqualObjects(imageData.URL, self.builder.URL);
    XCTAssertEqual(imageData.localImage, self.builder.localImage);
    XCTAssertEqualObjects(imageData.placeholderIdentifier, @"placeholder");
}

- (void)testEmptyBuilderProducingNil
{
    XCTAssertNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testOnlyURLNotProducingNil
{
    self.builder.URL = [NSURL URLWithString:@"cdn.spotify.com/hub"];
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testLocalImageOnlyNotProducingNil
{
    self.builder.localImage = [UIImage new];
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testOnlyPlaceholderIdentifierNotProducingNil
{
    self.builder.placeholderIdentifier = @"placeholder";
    XCTAssertNotNil([self.builder buildWithIdentifier:nil type:HUBComponentImageTypeMain]);
}

- (void)testAddingJSONData
{
    NSURL * const imageURL = [NSURL URLWithString:@"http://cdn.spotify.com/image"];
    
    NSDictionary * const dictionary = @{
        @"style": @"circular",
        @"uri": imageURL.absoluteString,
        @"placeholder": @"place_holder"
    };
    
    [self.builder addDataFromJSONDictionary:dictionary];
    
    XCTAssertEqual(self.builder.style, HUBComponentImageStyleCircular);
    XCTAssertEqualObjects(self.builder.URL, imageURL);
    XCTAssertEqualObjects(self.builder.placeholderIdentifier, @"place_holder");
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
