#import <XCTest/XCTest.h>

#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"

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

@end
