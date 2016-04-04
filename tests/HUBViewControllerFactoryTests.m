#import <XCTest/XCTest.h>

#import "HUBViewControllerFactory.h"
#import "HUBManager.h"
#import "HUBFeatureRegistry.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBContentProviderMock.h"
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
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                      imageLoaderFactory:imageLoaderFactory
                                               defaultComponentNamespace:@"default"
                                                   fallbackComponentName:@"fallback"
                                                  componentLayoutManager:componentLayoutManager];
}

#pragma mark - Tests

- (void)testCreatingViewControllerForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    HUBContentProviderFactoryMock * const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[contentProvider]];
    
    [self.manager.featureRegistry registerFeatureWithIdentifier:@"feature"
                                                    rootViewURI:viewURI
                                       contentProviderFactories:@[contentProviderFactory]
                                     customJSONSchemaIdentifier:nil
                                               viewURIQualifier:nil];
    
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
