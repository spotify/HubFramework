#import <XCTest/XCTest.h>

#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentMock.h"

@interface HUBComponentRegistryTests : XCTestCase

@property (nonatomic, strong) HUBComponentFallbackHandlerMock *fallbackHandler;
@property (nonatomic, strong) HUBComponentRegistryImplementation *registry;

@end

@implementation HUBComponentRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.fallbackHandler = [HUBComponentFallbackHandlerMock new];
    self.registry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:self.fallbackHandler];
}

#pragma mark - Tests

- (void)testRegisteringComponents
{
    HUBComponentMock * const componentA = [HUBComponentMock new];
    HUBComponentMock * const componentB = [HUBComponentMock new];
    
    NSDictionary * const components = @{
        @"A": componentA,
        @"B": componentB
    };
    
    [self.registry registerComponents:components forNamespace:@"namespace"];
    
    HUBComponentModelImplementation * const componentAModel = [self mockedComponentModelWithComponentIdentifier:@"namespace:A"];
    XCTAssertEqual([self.registry componentForModel:componentAModel], componentA);
    
    HUBComponentModelImplementation * const componentBModel = [self mockedComponentModelWithComponentIdentifier:@"namespace:B"];
    XCTAssertEqual([self.registry componentForModel:componentBModel], componentB);
}

- (void)testRegisteringAlreadyRegisteredComponentThrows
{
    HUBComponentMock * const component = [HUBComponentMock new];
    NSDictionary * const components = @{@"A": component};
    [self.registry registerComponents:components forNamespace:@"namespace"];
    
    XCTAssertThrows([self.registry registerComponents:components forNamespace:@"namespace"]);
    
    // Registering the same component but under a different namespace should work
    [self.registry registerComponents:components forNamespace:@"other_namespace"];
}

- (void)testFallbackComponent
{
    HUBComponentMock * const component = [HUBComponentMock new];
    [self.registry registerComponents:@{@"A": component} forNamespace:@"namespace"];
    
    HUBComponentMock * const fallbackComponent = [HUBComponentMock new];
    [self.registry registerComponents:@{self.fallbackHandler.fallbackComponentIdentifier: fallbackComponent}
                         forNamespace:self.fallbackHandler.fallbackComponentNamespace];
    
    HUBComponentModelImplementation * const model = [self mockedComponentModelWithComponentIdentifier:@"not_registered"];
    XCTAssertEqual([self.registry componentForModel:model], fallbackComponent);
}

- (void)testAllComponentIdentifiers
{
    [self.registry registerComponents:@{@"componentA": [HUBComponentMock new]} forNamespace:@"namespaceA"];
    [self.registry registerComponents:@{@"componentB": [HUBComponentMock new]} forNamespace:@"namespaceB"];
    
    NSArray * const expectedComponentIdentifiers = @[@"namespaceA:componentA", @"namespaceB:componentB"];
    NSArray * const actualComponentIdentifiers = self.registry.allComponentIdentifiers;
    
    XCTAssertEqual(actualComponentIdentifiers.count, expectedComponentIdentifiers.count);
    
    for (NSString * const identifier in expectedComponentIdentifiers) {
        XCTAssertTrue([actualComponentIdentifiers containsObject:identifier]);
    }
}

#pragma mark - Utilities

- (HUBComponentModelImplementation *)mockedComponentModelWithComponentIdentifier:(NSString *)componentIdentifier
{
    NSString * const identifier = [NSUUID UUID].UUIDString;
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                   componentIdentifier:componentIdentifier
                                                     contentIdentifier:nil
                                                                 title:nil
                                                              subtitle:nil
                                                        accessoryTitle:nil
                                                       descriptionText:nil
                                                         mainImageData:nil
                                                   backgroundImageData:nil
                                                       customImageData:@{}
                                                             targetURL:nil
                                                targetInitialViewModel:nil
                                                            customData:nil
                                                           loggingData:nil
                                                                  date:nil];
}

@end




