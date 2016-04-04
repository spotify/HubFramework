#import <XCTest/XCTest.h>

#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBViewURIQualifierMock.h"

@interface HUBFeatureRegistryTests : XCTestCase

@property (nonatomic, strong) HUBFeatureRegistryImplementation *registry;

@end

@implementation HUBFeatureRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.registry = [HUBFeatureRegistryImplementation new];
}

#pragma mark - Tests

- (void)testConflictingRootViewURIsTriggerAssert
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:@"featureA"
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:nil];
    
    XCTAssertThrows([self.registry registerFeatureWithIdentifier:@"featureB"
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:nil]);
}

- (void)testConflictingIdentifiersTriggerAssert
{
    NSString * const identifier = @"identifier";
    
    NSURL * const rootViewURIA = [NSURL URLWithString:@"spotify:hub:framework:a"];
    NSURL * const rootViewURIB = [NSURL URLWithString:@"spotify:hub:framework:b"];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:identifier
                                     rootViewURI:rootViewURIA
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:nil];
    
    XCTAssertThrows([self.registry registerFeatureWithIdentifier:identifier
                                                     rootViewURI:rootViewURIB
                                        contentProviderFactories:@[contentProviderFactory]
                                      customJSONSchemaIdentifier:nil
                                                viewURIQualifier:nil]);
}

- (void)testRegistrationPropertyAssignment
{
    NSString * const featureIdentifier = @"identifier";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    NSString * const customJSONSchemaIdentifier = @"JSON Schema";
    id<HUBViewURIQualifier> const viewURIQualifier = [[HUBViewURIQualifierMock alloc] initWithDisqualifiedViewURIs:@[]];
    
    [self.registry registerFeatureWithIdentifier:featureIdentifier
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:customJSONSchemaIdentifier
                                viewURIQualifier:viewURIQualifier];
    
    HUBFeatureRegistration * const registration = [self.registry featureRegistrationForViewURI:rootViewURI];
    XCTAssertEqualObjects(registration.featureIdentifier, featureIdentifier);
    XCTAssertEqualObjects(registration.rootViewURI, rootViewURI);
    XCTAssertEqualObjects(registration.contentProviderFactories, @[contentProviderFactory]);
    XCTAssertEqualObjects(registration.customJSONSchemaIdentifier, customJSONSchemaIdentifier);
    XCTAssertEqual(registration.viewURIQualifier, viewURIQualifier);
}

- (void)testSubviewMatch
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:@"feature"
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:nil];
    
    NSURL * const subviewURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@:subview", rootViewURI.absoluteString]];
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:subviewURI].rootViewURI, rootViewURI);
}

- (void)testDisqualifyingRootViewURI
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    id<HUBViewURIQualifier> const viewURIQualifier = [[HUBViewURIQualifierMock alloc] initWithDisqualifiedViewURIs:@[rootViewURI]];
    
    [self.registry registerFeatureWithIdentifier:@"feature"
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:viewURIQualifier];
    
    XCTAssertNil([self.registry featureRegistrationForViewURI:rootViewURI]);
    
    NSURL * const subviewURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@:subview", rootViewURI.absoluteString]];
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:subviewURI].rootViewURI, rootViewURI);
}

- (void)testDisqualifyingSubviewURI
{
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    NSURL * const subviewURI = [NSURL URLWithString:[NSString stringWithFormat:@"%@:subview", rootViewURI.absoluteString]];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    id<HUBViewURIQualifier> const viewURIQualifier = [[HUBViewURIQualifierMock alloc] initWithDisqualifiedViewURIs:@[subviewURI]];
    
    [self.registry registerFeatureWithIdentifier:@"feature"
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:viewURIQualifier];
    
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:rootViewURI].rootViewURI, rootViewURI);
    XCTAssertNil([self.registry featureRegistrationForViewURI:subviewURI]);
}

- (void)testUnregisteringFeature
{
    NSString * const identifier = @"Awesome feature";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:identifier
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:nil];
    
    [self.registry unregisterFeatureWithIdentifier:identifier];
    
    // The feature should now be free to be re-registered without triggering an assert
    [self.registry registerFeatureWithIdentifier:identifier
                                     rootViewURI:rootViewURI
                        contentProviderFactories:@[contentProviderFactory]
                      customJSONSchemaIdentifier:nil
                                viewURIQualifier:nil];
}

@end
