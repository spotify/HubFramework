#import <XCTest/XCTest.h>

#import "HUBViewControllerFactory.h"
#import "HUBManager.h"
#import "HUBFeatureRegistry.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBContentProviderMock.h"
#import "HUBImageLoaderFactoryMock.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBViewURIPredicate.h"
#import "HUBContentReloadPolicyMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBComponentFallbackHandlerMock.h"

@interface HUBViewControllerFactoryTests : XCTestCase

@property (nonatomic, strong) HUBContentReloadPolicyMock *defaultContentReloadPolicy;
@property (nonatomic, strong) HUBManager *manager;

@end

@implementation HUBViewControllerFactoryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.defaultContentReloadPolicy = [HUBContentReloadPolicyMock new];
    
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    id<HUBImageLoaderFactory> const imageLoaderFactory = [HUBImageLoaderFactoryMock new];
    id<HUBComponentLayoutManager> const componentLayoutManager = [HUBComponentLayoutManagerMock new];
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    
    self.manager = [[HUBManager alloc] initWithConnectivityStateResolver:connectivityStateResolver
                                                      imageLoaderFactory:imageLoaderFactory
                                              defaultContentReloadPolicy:self.defaultContentReloadPolicy
                                                  componentLayoutManager:componentLayoutManager
                                                componentFallbackHandler:componentFallbackHandler];
}

#pragma mark - Tests

- (void)testCreatingViewControllerForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    HUBContentProviderFactoryMock * const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[contentProvider]];
    
    [self.manager.featureRegistry registerFeatureWithIdentifier:@"feature"
                                               viewURIPredicate:viewURIPredicate
                                       contentProviderFactories:@[contentProviderFactory]
                                            contentReloadPolicy:nil
                                     customJSONSchemaIdentifier:nil];
    
    XCTAssertTrue([self.manager.viewControllerFactory canCreateViewControllerForViewURI:viewURI]);
    XCTAssertNotNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

- (void)testCreatingViewControllerForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unknown"];
    XCTAssertFalse([self.manager.viewControllerFactory canCreateViewControllerForViewURI:viewURI]);
    XCTAssertNil([self.manager.viewControllerFactory createViewControllerForViewURI:viewURI]);
}

- (void)testDefaultContentReloadPolicyUsedIfFeatureDidNotSupplyOne
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithViewURI:viewURI];
    HUBContentProviderMock * const contentProvider = [HUBContentProviderMock new];
    HUBContentProviderFactoryMock * const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[contentProvider]];
    
    [self.manager.featureRegistry registerFeatureWithIdentifier:@"feature"
                                               viewURIPredicate:viewURIPredicate
                                       contentProviderFactories:@[contentProviderFactory]
                                            contentReloadPolicy:nil
                                     customJSONSchemaIdentifier:nil];
    
    UIViewController * const viewController = [self.manager.viewControllerFactory createViewControllerForViewURI:viewURI];
    [viewController viewWillAppear:YES];
    [viewController viewWillAppear:YES];
    XCTAssertEqual(self.defaultContentReloadPolicy.numberOfRequests, (NSUInteger)1);
}

@end
