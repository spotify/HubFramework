#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBComponentFallbackHandlerMock.h"

@interface HUBManagerTests : XCTestCase

@end

@implementation HUBManagerTests

- (void)testRegistries
{
    id<HUBComponentFallbackHandler> const fallbackHandler = [HUBComponentFallbackHandlerMock new];
    HUBManager * const manager = [[HUBManager alloc] initWithComponentFallbackHandler:fallbackHandler];
    
    XCTAssertNotNil(manager.featureRegistry);
    XCTAssertNotNil(manager.componentRegistry);
    XCTAssertNotNil(manager.JSONSchemaRegistry);
}

@end
