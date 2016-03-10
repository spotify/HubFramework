#import <XCTest/XCTest.h>

#import "HUBViewModelLoaderFactoryImplementation.h"
#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureConfiguration.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBConnectivityStateResolverMock.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBRemoteContentProviderMock.h"
#import "HUBRemoteContentURLResolverMock.h"
#import "HUBViewModelLoader.h"
#import "HUBDataLoaderFactoryMock.h"
#import "HUBDataLoaderMock.h"

@interface HUBViewModelLoaderFactoryTests : XCTestCase

@property (nonatomic, strong) HUBDataLoaderFactoryMock *dataLoaderFactory;
@property (nonatomic, strong) HUBFeatureRegistryImplementation *featureRegistry;
@property (nonatomic, copy) NSString *defaultComponentNamespace;
@property (nonatomic, strong) HUBViewModelLoaderFactoryImplementation *viewModelLoaderFactory;

@end

@implementation HUBViewModelLoaderFactoryTests

- (void)setUp
{
    [super setUp];
    
    self.dataLoaderFactory = [HUBDataLoaderFactoryMock new];
    self.featureRegistry = [[HUBFeatureRegistryImplementation alloc] initWithDataLoaderFactory:self.dataLoaderFactory];
    self.defaultComponentNamespace = @"default";
    
    HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [HUBJSONSchemaRegistryImplementation new];
    id<HUBConnectivityStateResolver> const connectivityStateResolver = [HUBConnectivityStateResolverMock new];
    
    self.viewModelLoaderFactory = [[HUBViewModelLoaderFactoryImplementation alloc] initWithFeatureRegistry:self.featureRegistry
                                                                                        JSONSchemaRegistry:JSONSchemaRegistry
                                                                                 defaultComponentNamespace:self.defaultComponentNamespace
                                                                                 connectivityStateResolver:connectivityStateResolver];
}

- (void)testCreatingViewModelLoaderForValidViewURI
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];

    HUBContentProviderFactoryMock * const contentProviderFactory = [HUBContentProviderFactoryMock new];
    contentProviderFactory.remoteContentProvider = [HUBRemoteContentProviderMock new];
    
    id<HUBFeatureConfiguration> const featureConfiguration = [self.featureRegistry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                                   rootViewURI:viewURI
                                                                                                  remoteContentProviderFactory:contentProviderFactory
                                                                                                   localContentProviderFactory:nil];
    
    [self.featureRegistry registerFeatureWithConfiguration:featureConfiguration];
    
    XCTAssertTrue([self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI]);
    XCTAssertNotNil([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testCreatingViewModelLoaderForInvalidViewURIReturnsNil
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:unrecognized"];
    XCTAssertFalse([self.viewModelLoaderFactory canCreateViewModelLoaderForViewURI:viewURI]);
    XCTAssertNil([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testNoContentProviderCreatedThrows
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBContentProviderFactoryMock * const contentProviderFactory = [HUBContentProviderFactoryMock new];
    id<HUBFeatureConfiguration> const featureConfiguration = [self.featureRegistry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                                   rootViewURI:viewURI
                                                                                                  remoteContentProviderFactory:contentProviderFactory
                                                                                                   localContentProviderFactory:contentProviderFactory];
    
    [self.featureRegistry registerFeatureWithConfiguration:featureConfiguration];
    
    XCTAssertThrows([self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI]);
}

- (void)testDataLoaderFactoryUsedIfFeatureUsesRemoteContentURLResolver
{
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    HUBRemoteContentURLResolverMock * const URLResolver = [HUBRemoteContentURLResolverMock new];
    URLResolver.contentURL = [NSURL URLWithString:@"https://remote.content"];
    
    id<HUBFeatureConfiguration> const featureConfiguration = [self.featureRegistry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                                   rootViewURI:viewURI
                                                                                                      remoteContentURLResolver:URLResolver];
    
    [self.featureRegistry registerFeatureWithConfiguration:featureConfiguration];
    
    id<HUBViewModelLoader> const viewModelLoader = [self.viewModelLoaderFactory createViewModelLoaderForViewURI:viewURI];
    [viewModelLoader loadViewModel];
    XCTAssertEqualObjects(self.dataLoaderFactory.lastCreatedDataLoader.currentDataURL, URLResolver.contentURL);
    XCTAssertEqualObjects(self.dataLoaderFactory.lastCreatedDataLoader.featureIdentifier, featureConfiguration.featureIdentifier);
}

@end
