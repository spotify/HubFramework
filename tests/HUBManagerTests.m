#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBConnectivityStateResolverMock.h"

@interface HUBManagerTests : XCTestCase

@end

@implementation HUBManagerTests

- (void)testRegistries
{
    id<HUBComponentFallbackHandler> const fallbackHandler = [HUBComponentFallbackHandlerMock new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    HUBManager * const manager = [[HUBManager alloc] initWithComponentFallbackHandler:fallbackHandler
                                                            connectivityStateResolver:connectivityStateResolver];
    
    XCTAssertNotNil(manager.featureRegistry);
    XCTAssertNotNil(manager.componentRegistry);
    XCTAssertNotNil(manager.JSONSchemaRegistry);
}

@end
