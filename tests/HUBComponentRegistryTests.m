#import <XCTest/XCTest.h>

#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentMock.h"
#import "HUBComponentModelMock.h"

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
    
    HUBComponentModelMock * const componentAModel = [[HUBComponentModelMock alloc] initWithComponentIdentifier:@"namespace:A"];
    XCTAssertEqual([self.registry componentForModel:componentAModel], componentA);
    
    HUBComponentModelMock * const componentBModel = [[HUBComponentModelMock alloc] initWithComponentIdentifier:@"namespace:B"];
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
    
    HUBComponentModelMock * const model = [[HUBComponentModelMock alloc] initWithComponentIdentifier:@"not_registered"];
    XCTAssertEqual([self.registry componentForModel:model], fallbackComponent);
}

@end




