#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBImageLoaderFactoryMock.h"
#import "HUBComponentLayoutManagerMock.h"

@interface HUBManagerTests : XCTestCase

@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBManagerTests

- (void)setUp
{
    [super setUp];

    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBImageLoaderFactory> const imageLoaderFactory = [HUBImageLoaderFactoryMock new];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                      imageLoaderFactory:imageLoaderFactory
                                               defaultComponentNamespace:@"default"
                                                   fallbackComponentName:@"fallback"
                                                  componentLayoutManager:componentLayoutManager];
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
