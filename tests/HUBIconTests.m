#import <XCTest/XCTest.h>

#import "HUBIconImplementation.h"
#import "HUBIconImageResolverMock.h"

@interface HUBIconTests : XCTestCase

@property (nonatomic, strong) HUBIconImageResolverMock *imageResolver;

@end

@implementation HUBIconTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.imageResolver = [HUBIconImageResolverMock new];
}

#pragma mark - Tests

- (void)testIdentifierAssignment
{
    HUBIconImplementation * const icon = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                             imageResolver:self.imageResolver
                                                                             isPlaceholder:NO];
    
    XCTAssertEqualObjects(icon.identifier, @"id");
}

- (void)testResolvingComponentImage
{
    UIImage * const image = [UIImage new];
    self.imageResolver.imageForComponentIcons = image;
    
    HUBIconImplementation * const icon = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                             imageResolver:self.imageResolver
                                                                             isPlaceholder:NO];
    
    XCTAssertEqual([icon imageWithSize:CGSizeZero color:[UIColor redColor]], image);
}

- (void)testResolvingPlaceholderImage
{
    UIImage * const image = [UIImage new];
    self.imageResolver.imageForPlaceholderIcons = image;
    
    HUBIconImplementation * const icon = [[HUBIconImplementation alloc] initWithIdentifier:@"id"
                                                                             imageResolver:self.imageResolver
                                                                             isPlaceholder:YES];
    
    XCTAssertEqual([icon imageWithSize:CGSizeZero color:[UIColor redColor]], image);
}

@end
