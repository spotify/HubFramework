#import <XCTest/XCTest.h>

#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentMock.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentFactoryMock.h"

static NSString * const DefaultNamespace = @"default";

@interface HUBComponentRegistryTests : XCTestCase

@property (nonatomic, strong) HUBComponentIdentifier *fallbackComponentIdentifier;
@property (nonatomic, strong) HUBComponentRegistryImplementation *registry;

@end

@implementation HUBComponentRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.fallbackComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"fallbackNamespace" name:@"fallbackIdentifier"];
    self.registry = [[HUBComponentRegistryImplementation alloc] initWithFallbackComponentIdentifier:self.fallbackComponentIdentifier];
}

#pragma mark - Tests

- (void)testRegisteringComponentFactory
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBComponentMock * const component = [HUBComponentMock new];
    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:@{componentIdentifier.componentName: component}];
    
    [self.registry registerComponentFactory:factory forNamespace:componentIdentifier.componentNamespace];

    XCTAssertEqual([self.registry createComponentForIdentifier:componentIdentifier], component);
}

- (void)testRegisteringAlreadyRegisteredFactoryThrows
{
    HUBComponentMock * const component = [HUBComponentMock new];
    NSDictionary * const components = @{@"A": component};
    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:components];

    [self.registry registerComponentFactory:factory forNamespace:@"namespace"];

    XCTAssertThrows([self.registry registerComponentFactory:factory forNamespace:@"namespace"]);

    // Registering the same component but under a different namespace should work
    [self.registry registerComponentFactory:factory forNamespace:@"other_namespace"];
}

- (void)testFallbackComponentCreatedForUnknownNamespace
{
    HUBComponentMock * const fallbackComponent = [HUBComponentMock new];
    NSDictionary * const fallbackFactoryComponents = @{self.fallbackComponentIdentifier.componentName: fallbackComponent};
    HUBComponentFactoryMock * const fallbackFactory = [[HUBComponentFactoryMock alloc] initWithComponents:fallbackFactoryComponents];
    
    [self.registry registerComponentFactory:fallbackFactory forNamespace:self.fallbackComponentIdentifier.componentNamespace];
    
    HUBComponentIdentifier * const unknownNamespaceIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"unknown" name:@"name"];
    XCTAssertEqual([self.registry createComponentForIdentifier:unknownNamespaceIdentifier], fallbackComponent);
}

- (void)testFallbackComponentCreatedWhenFactoryReturnsNil
{
    HUBComponentMock * const fallbackComponent = [HUBComponentMock new];
    NSDictionary * const factoryComponents = @{self.fallbackComponentIdentifier.componentName: fallbackComponent};
    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:factoryComponents];
    
    [self.registry registerComponentFactory:factory forNamespace:self.fallbackComponentIdentifier.componentNamespace];
    
    HUBComponentIdentifier * const unknownNameIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:self.fallbackComponentIdentifier.componentNamespace
                                                                                                        name:@"unknown"];
    
    XCTAssertEqual([self.registry createComponentForIdentifier:unknownNameIdentifier], fallbackComponent);
}

- (void)testFallbackComponentFromAnotherFactory
{
    HUBComponentMock * const fallbackComponent = [HUBComponentMock new];
    NSDictionary * const fallbackFactoryComponents = @{self.fallbackComponentIdentifier.componentName: fallbackComponent};
    HUBComponentFactoryMock * const fallbackFactory = [[HUBComponentFactoryMock alloc] initWithComponents:fallbackFactoryComponents];
    [self.registry registerComponentFactory:fallbackFactory forNamespace:self.fallbackComponentIdentifier.componentNamespace];
    
    HUBComponentFactoryMock * const emptyFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    NSString * const emptyFactoryNamespace = @"empty";
    [self.registry registerComponentFactory:emptyFactory forNamespace:emptyFactoryNamespace];
    
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:emptyFactoryNamespace
                                                                                                      name:@"unknown"];
    
    XCTAssertEqual([self.registry createComponentForIdentifier:componentIdentifier], fallbackComponent);
}

- (void)testFallbackComponentCreationFailureThrows
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    XCTAssertThrows([self.registry createComponentForIdentifier:componentIdentifier]);
}

#pragma mark - Utilities

- (HUBComponentModelImplementation *)mockedComponentModelWithComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier
{
    NSString * const identifier = [NSUUID UUID].UUIDString;

    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                   componentIdentifier:componentIdentifier
                                                     contentIdentifier:nil
                                                                 index:0
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
                                                                  date:nil
                                                  childComponentModels:nil];
}

@end
