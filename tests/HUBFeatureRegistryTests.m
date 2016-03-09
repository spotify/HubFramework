#import <XCTest/XCTest.h>

#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureConfiguration.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBRemoteContentURLResolverMock.h"
#import "HUBViewURIQualifierMock.h"

@interface HUBFeatureRegistryTests : XCTestCase

@property (nonatomic, strong) HUBFeatureRegistryImplementation *registry;

@end

@implementation HUBFeatureRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    id<HUBDefaultRemoteContentProviderFactory> const defaultRemoteContentProviderFactory = [HUBContentProviderFactoryMock new];
    self.registry = [[HUBFeatureRegistryImplementation alloc] initWithDefaultRemoteContentProviderFactory:defaultRemoteContentProviderFactory];
}

#pragma mark - Tests

- (void)testConfigurationPropertyAssignmentWithRemoteContentURLResolver
{
    NSString * const featureIdentifier = @"Awesome feature";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:featureIdentifier
                                                                                                     rootViewURI:rootViewURI
                                                                                        remoteContentURLResolver:remoteContentURLResolver];
    
    XCTAssertEqualObjects(configuration.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(configuration.rootViewURI, rootViewURI);
    XCTAssertEqual(configuration.remoteContentURLResolver, remoteContentURLResolver);
}

- (void)testConfigurationPropertyAssignmentWithContentProviders
{
    NSString * const featureIdentifier = @"Awesome feature";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentProviderFactory> const remoteContentProviderFactory = [HUBContentProviderFactoryMock new];
    id<HUBLocalContentProviderFactory> const localContentProviderFactory = [HUBContentProviderFactoryMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:featureIdentifier
                                                                                                     rootViewURI:rootViewURI
                                                                                    remoteContentProviderFactory:remoteContentProviderFactory
                                                                                     localContentProviderFactory:localContentProviderFactory];
    
    XCTAssertEqualObjects(configuration.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(configuration.rootViewURI, rootViewURI);
    XCTAssertEqual(configuration.remoteContentProviderFactory, remoteContentProviderFactory);
    XCTAssertEqual(configuration.localContentProviderFactory, localContentProviderFactory);
}

- (void)testConflictingRootViewURIsTriggerAssert
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configurationA = [self.registry createConfigurationForFeatureWithIdentifier:@"featureA"
                                                                                                      rootViewURI:rootViewURI
                                                                                         remoteContentURLResolver:remoteContentURLResolver];
    
    id<HUBFeatureConfiguration> const configurationB = [self.registry createConfigurationForFeatureWithIdentifier:@"featureB"
                                                                                                      rootViewURI:rootViewURI
                                                                                         remoteContentURLResolver:remoteContentURLResolver];
    
    [self.registry registerFeatureWithConfiguration:configurationA];
    XCTAssertThrows([self.registry registerFeatureWithConfiguration:configurationB]);
}

- (void)testConflictingIdentifiersTriggerAssert
{
    NSString * const identifier = @"identifier";
    
    NSURL * const rootViewURIA = [NSURL URLWithString:@"spotify:hub:framework:a"];
    NSURL * const rootViewURIB = [NSURL URLWithString:@"spotify:hub:framework:b"];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configurationA = [self.registry createConfigurationForFeatureWithIdentifier:identifier
                                                                                                      rootViewURI:rootViewURIA
                                                                                         remoteContentURLResolver:remoteContentURLResolver];
    
    id<HUBFeatureConfiguration> const configurationB = [self.registry createConfigurationForFeatureWithIdentifier:identifier
                                                                                                      rootViewURI:rootViewURIB
                                                                                         remoteContentURLResolver:remoteContentURLResolver];
    
    [self.registry registerFeatureWithConfiguration:configurationA];
    XCTAssertThrows([self.registry registerFeatureWithConfiguration:configurationB]);
}

- (void)testRegistrationAndConfigurationMatch
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentProviderFactory> const remoteContentProviderFactory = [HUBContentProviderFactoryMock new];
    id<HUBLocalContentProviderFactory> const localContentProviderFactory = [HUBContentProviderFactoryMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                     rootViewURI:rootViewURI
                                                                                    remoteContentProviderFactory:remoteContentProviderFactory
                                                                                     localContentProviderFactory:localContentProviderFactory];
    
    configuration.customJSONSchemaIdentifier = @"custom schema";
    configuration.viewURIQualifier = [[HUBViewURIQualifierMock alloc] initWithDisqualifiedViewURIs:@[]];
    [self.registry registerFeatureWithConfiguration:configuration];
    
    HUBFeatureRegistration * const registration = [self.registry featureRegistrationForViewURI:rootViewURI];
    XCTAssertEqualObjects(registration.featureIdentifier, configuration.featureIdentifier);
    XCTAssertEqualObjects(registration.rootViewURI, configuration.rootViewURI);
    XCTAssertEqual(registration.remoteContentProviderFactory, configuration.remoteContentProviderFactory);
    XCTAssertEqual(registration.localContentProviderFactory, configuration.localContentProviderFactory);
    XCTAssertEqualObjects(registration.customJSONSchemaIdentifier, configuration.customJSONSchemaIdentifier);
    XCTAssertEqual(registration.viewURIQualifier, configuration.viewURIQualifier);
}

- (void)testSubviewMatch
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                     rootViewURI:rootViewURI
                                                                                        remoteContentURLResolver:remoteContentURLResolver];
    
    [self.registry registerFeatureWithConfiguration:configuration];
    
    NSURL * const subviewURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@:subview", rootViewURI.absoluteString]];
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:subviewURI].rootViewURI, rootViewURI);
}

- (void)testDisqualifyingRootViewURI
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                     rootViewURI:rootViewURI
                                                                                        remoteContentURLResolver:remoteContentURLResolver];
    
    configuration.viewURIQualifier = [[HUBViewURIQualifierMock alloc] initWithDisqualifiedViewURIs:@[rootViewURI]];
    [self.registry registerFeatureWithConfiguration:configuration];
    
    XCTAssertNil([self.registry featureRegistrationForViewURI:rootViewURI]);
    
    NSURL * const subviewURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@:subview", rootViewURI.absoluteString]];
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:subviewURI].rootViewURI, rootViewURI);
}

- (void)testDisqualifyingSubviewURI
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    NSURL * const subviewURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@:subview", rootViewURI.absoluteString]];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:@"feature"
                                                                                                     rootViewURI:rootViewURI
                                                                                        remoteContentURLResolver:remoteContentURLResolver];
    
    configuration.viewURIQualifier = [[HUBViewURIQualifierMock alloc] initWithDisqualifiedViewURIs:@[subviewURI]];
    [self.registry registerFeatureWithConfiguration:configuration];
    
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:rootViewURI].rootViewURI, configuration.rootViewURI);
    XCTAssertNil([self.registry featureRegistrationForViewURI:subviewURI]);
}

- (void)testUnregisteringFeature
{
    NSString * const identifier = @"Awesome feature";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBRemoteContentURLResolver> const remoteContentURLResolver = [HUBRemoteContentURLResolverMock new];
    
    id<HUBFeatureConfiguration> const configuration = [self.registry createConfigurationForFeatureWithIdentifier:identifier
                                                                                                     rootViewURI:rootViewURI
                                                                                        remoteContentURLResolver:remoteContentURLResolver];
    
    [self.registry registerFeatureWithConfiguration:configuration];
    [self.registry unregisterFeatureWithIdentifier:identifier];
    [self.registry registerFeatureWithConfiguration:configuration];
}

@end
