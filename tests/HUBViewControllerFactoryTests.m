#import <XCTest/XCTest.h>

#import "HUBViewControllerFactory.h"
#import "HUBManager.h"
#import "HUBFeatureRegistry.h"
#import "HUBFeatureConfiguration.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBRemoteContentProviderMock.h"
#import "HUBDataLoaderFactoryMock.h"
#import "HUBImageLoaderFactoryMock.h"
#import "HUBComponentLayoutManagerMock.h"

@interface HUBViewControllerFactoryTests : XCTestCase

@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBViewControllerFactoryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBImageLoaderFactory> const imageLoaderFactory = [HUBImageLoaderFactoryMock new];
    id<HUBDataLoaderFactory> const dataLoaderFactory = [HUBDataLoaderFactoryMock new];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                       dataLoaderFactory:dataLoaderFactory
                                                      imageLoaderFactory:imageLoaderFactory
                                               defaultComponentNamespace:@"default"
                                                   fallbackComponentName:@"fallback"
                                                  componentLayoutManager:componentLayoutManager];
}

#pragma mark - Tests

- (void)testCreatingViewControllerForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBContentProviderFactoryMock * const contentProviderFactory = [HUBContentProviderFactoryMock new];
    contentProviderFactory.remoteContentProvider = [HUBRemoteContentProviderMock new];
    
    id<HUBFeatureConfiguration> const featureConfiguration = [self.manager.featureRegistry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                                   rootViewURI:viewURI
                                                                                                          remoteContentProviderFactory:contentProviderFactory
                                                                                                           localContentProviderFactory:nil];
    
    [self.manager.featureRegistry registerFeatureWithConfiguration:featureConfiguration];
    
    XCTAssertTrue([self.manager.viewControllerFactory canCreateViewControllerForViewURI:viewURI]);
    XCTAssertNotNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

- (void)testCreatingViewControllerForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unknown"];
    XCTAssertFalse([self.manager.viewControllerFactory canCreateViewControllerForViewURI:viewURI]);
    XCTAssertNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

@end
