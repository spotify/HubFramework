#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBImageLoaderFactoryMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBContentReloadPolicyMock.h"

@interface HUBManagerTests : XCTestCase

@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBManagerTests

- (void)setUp
{
    [super setUp];

    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBImageLoaderFactory> const imageLoaderFactory = [HUBImageLoaderFactoryMock new];
    id<HUBContentReloadPolicy> const defaultContentReloadPolicy = [HUBContentReloadPolicyMock new];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                      imageLoaderFactory:imageLoaderFactory
                                               defaultComponentNamespace:@"default"
                                                   fallbackComponentName:@"fallback"
                                              defaultContentReloadPolicy:defaultContentReloadPolicy
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
