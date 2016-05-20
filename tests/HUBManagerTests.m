#import <XCTest/XCTest.h>

#import "HUBManager.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentOperationFactoryMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"

@interface HUBManagerTests : XCTestCase

@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBManagerTests

- (void)setUp
{
    [super setUp];

    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBContentReloadPolicy> const defaultContentReloadPolicy = [HUBContentReloadPolicyMock new];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                  componentLayoutManager:componentLayoutManager
                                                componentFallbackHandler:componentFallbackHandler
                                                      imageLoaderFactory:nil
                                                       iconImageResolver:nil
                                              defaultContentReloadPolicy:defaultContentReloadPolicy
                                        prependedContentOperationFactory:nil
                                         appendedContentOperationFactory:nil];
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
