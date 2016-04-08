#import <XCTest/XCTest.h>

#import "HUBFeatureRegistryImplementation.h"
#import "HUBFeatureRegistration.h"
#import "HUBContentProviderFactoryMock.h"
#import "HUBViewURIPredicate.h"

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

- (void)testConflictingIdentifiersTriggerAssert
{
    NSString * const identifier = @"identifier";
    
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:identifier
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil];
    
    XCTAssertThrows([self.registry registerFeatureWithIdentifier:identifier
                                                viewURIPredicate:viewURIPredicate
                                        contentProviderFactories:@[contentProviderFactory]
                                             contentReloadPolicy:nil
                                      customJSONSchemaIdentifier:nil]);
}

- (void)testRegistrationPropertyAssignment
{
    NSString * const featureIdentifier = @"identifier";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    NSString * const customJSONSchemaIdentifier = @"JSON Schema";
    
    [self.registry registerFeatureWithIdentifier:featureIdentifier
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:customJSONSchemaIdentifier];
    
    HUBFeatureRegistration * const registration = [self.registry featureRegistrationForViewURI:rootViewURI];
    XCTAssertEqualObjects(registration.featureIdentifier, featureIdentifier);
    XCTAssertEqual(registration.viewURIPredicate, viewURIPredicate);
    XCTAssertEqualObjects(registration.contentProviderFactories, @[contentProviderFactory]);
    XCTAssertEqualObjects(registration.customJSONSchemaIdentifier, customJSONSchemaIdentifier);
}

- (void)testPredicateViewURIDisqualification
{
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return NO;
    }];
    
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:@"feature"
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    XCTAssertNil([self.registry featureRegistrationForViewURI:viewURI]);
}

- (void)testFeatureRegistrationOrderDeterminingViewURIEvaluationOrder
{
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithBlock:^BOOL(NSURL *evaluatedViewURI) {
        return YES;
    }];
    
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:@"featureA"
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil];
    
    [self.registry registerFeatureWithIdentifier:@"featureB"
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    XCTAssertEqualObjects([self.registry featureRegistrationForViewURI:viewURI].featureIdentifier, @"featureA");
}

- (void)testUnregisteringFeature
{
    NSString * const identifier = @"Awesome feature";
    NSURL * const rootViewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    HUBViewURIPredicate * const viewURIPredicate = [HUBViewURIPredicate predicateWithRootViewURI:rootViewURI];
    id<HUBContentProviderFactory> const contentProviderFactory = [[HUBContentProviderFactoryMock alloc] initWithContentProviders:@[]];
    
    [self.registry registerFeatureWithIdentifier:identifier
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil];
    
    [self.registry unregisterFeatureWithIdentifier:identifier];
    
    // The feature should now be free to be re-registered without triggering an assert
    [self.registry registerFeatureWithIdentifier:identifier
                                viewURIPredicate:viewURIPredicate
                        contentProviderFactories:@[contentProviderFactory]
                             contentReloadPolicy:nil
                      customJSONSchemaIdentifier:nil];
}

@end
