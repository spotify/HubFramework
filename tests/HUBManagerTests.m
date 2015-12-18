#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBComponentFallbackHandlerMock.h"

@interface HUBManagerTests : XCTestCase

@end

@implementation HUBManagerTests

- (void)testComponentRegistrySetupOnInit
{
    id<HUBComponentFallbackHandler> const fallbackHandler = [HUBComponentFallbackHandlerMock new];
    XCTAssertNotNil([[HUBManager alloc] initWithComponentFallbackHandler:fallbackHandler].componentRegistry);
}

@end
