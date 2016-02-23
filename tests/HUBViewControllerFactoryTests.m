#import <XCTest/XCTest.h>

#import "HUBViewControllerFactory.h"
#import "HUBManager.h"
#import "HUBFeatureRegistry.h"
#import "HUBFeatureConfiguration.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBRemoteContentProviderMock.h"
#import "HUBImageLoaderFactoryMock.h"

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
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                      imageLoaderFactory:imageLoaderFactory
                                               defaultComponentNamespace:@"default"
                                                   fallbackComponentName:@"fallback"];
}

#pragma mark - Tests

- (void)testCreatingViewControllerForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBContentProviderFactoryMock * const contentProviderFactory = [HUBContentProviderFactoryMock new];
    contentProviderFactory.remoteContentProvider = [HUBRemoteContentProviderMock new];
    
    id<HUBFeatureConfiguration> const featureConfiguration = [self.manager.featureRegistry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                                   rootViewURI:viewURI
                                                                                                        contentProviderFactory:contentProviderFactory];
    
    [self.manager.featureRegistry registerFeatureWithConfiguration:featureConfiguration];
    
    XCTAssertNotNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

- (void)testCreatingViewControllerForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unknown"];
    XCTAssertNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

@end
