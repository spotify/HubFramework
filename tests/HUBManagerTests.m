#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBConnectivityStateResolverMock.h"

@interface HUBManagerTests : XCTestCase

@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBManagerTests

- (void)setUp
{
    [super setUp];
    
    id<HUBComponentFallbackHandler> const fallbackHandler = [HUBComponentFallbackHandlerMock new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.manager = [[HUBManager alloc] initWithComponentFallbackHandler:fallbackHandler
                                              connectivityStateResolver:connectivityStateResolver];
}

- (void)testRegistriesCreated
{
    XCTAssertNotNil(self.manager.featureRegistry);
    XCTAssertNotNil(self.manager.componentRegistry);
    XCTAssertNotNil(self.manager.JSONSchemaRegistry);
}

- (void)testFactoriesCreated
{
    XCTAssertNotNil(self.manager.viewModelLoaderFactory);
    XCTAssertNotNil(self.manager.viewControllerFactory);
}

@end
