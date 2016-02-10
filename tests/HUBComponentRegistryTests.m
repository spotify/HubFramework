#import <XCTest/XCTest.h>

#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentMock.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentFactoryMock.h"


static NSString * const DefaultNamespace = @"default";

@interface HUBComponentRegistryTests : XCTestCase

@property (nonatomic, strong) HUBComponentRegistryImplementation *registry;
@property (nonatomic, strong) HUBComponentFactoryMock *twoComponentFactory;
@property (nonatomic, strong) id<HUBComponent> componentA;
@property (nonatomic, strong) id<HUBComponent> componentB;
@end

@implementation HUBComponentRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];

    self.registry = [[HUBComponentRegistryImplementation alloc] initWithFallbackNamespace:DefaultNamespace];

    self.componentA = [HUBComponentMock new];
    self.componentB = [HUBComponentMock new];

    NSDictionary * const components = @{
        @"A": self.componentA,
        @"B": self.componentB
    };

    self.twoComponentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:components];
}

#pragma mark - Tests

- (void)testRegisteringComponentFactory
{
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"namespace"];

    HUBComponentIdentifier * const componentAIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"A"];
    HUBComponentModelImplementation * const componentAModel = [self mockedComponentModelWithComponentIdentifier:componentAIdentifier];
    XCTAssertEqual([self.registry componentForModel:componentAModel], self.componentA);

    HUBComponentIdentifier * const componentBIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"B"];
    HUBComponentModelImplementation * const componentBModel = [self mockedComponentModelWithComponentIdentifier:componentBIdentifier];
    XCTAssertEqual([self.registry componentForModel:componentBModel], self.componentB);
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

- (void)testFallbackComponentWithNoNamespace
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:nil
                                                                                                      name:@"componentA"];
    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];

    XCTAssertEqualObjects([self.registry componentIdentifierForModel:componentModel],
                          [[HUBComponentIdentifier alloc] initWithNamespace:DefaultNamespace name:@"componentA"]);
}

- (void)testFallbackComponentWithMissingNamespace
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"missing"
                                                                                                      name:@"componentA"];
    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];

    XCTAssertEqualObjects([self.registry componentIdentifierForModel:componentModel],
                          [[HUBComponentIdentifier alloc] initWithNamespace:DefaultNamespace name:@"componentA"]);
}

- (void)testFallbackComponentWithRegisteredHandlerReturningNil
{
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"aNamespace"];

    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"aNamespace"
                                                                                                      name:@"unknown"];
    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];

    XCTAssertEqualObjects([self.registry componentIdentifierForModel:componentModel],
                          [[HUBComponentIdentifier alloc] initWithNamespace:DefaultNamespace name:@"unknown"]);
}

- (void)testFactoryReturningNilForOwnNamespaceShouldGetDefaultInstead
{
    id<HUBComponent> const defaultComponent = [HUBComponentMock new];

    NSDictionary * const components = @{
            @"unhandled": defaultComponent
    };

    id<HUBComponentFactory> const defaultFactory = [[HUBComponentFactoryMock alloc] initWithComponents:components];

    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"namespace"];
    [self.registry registerComponentFactory:defaultFactory forNamespace:DefaultNamespace];

    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                                      name:@"unhandled"];
    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];


    id<HUBComponent> const resultComponent = [self.registry componentForModel:componentModel];
    XCTAssertEqual(resultComponent, defaultComponent);
}

- (void)testDefaultFactoryReturningNilComponentShouldAssert
{
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:DefaultNamespace];

    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                                      name:@"unhandled"];
    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];

    XCTAssertThrows([self.registry componentForModel:componentModel]);
}

- (void)testModelWithNoComponentIdentifierGetsADefaultComponent
{
    self.twoComponentFactory.defaultComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:nil
                                                                                                       name:@"A"];
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:DefaultNamespace];
    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:nil];

    XCTAssertEqual([self.registry componentForModel:componentModel], self.componentA);
}

- (void)testCanFallbackToAnotherFactoryNamespace
{
    HUBComponentIdentifier * const alias = [[HUBComponentIdentifier alloc] initWithNamespace:@"anotherNameSpace"
                                                                                        name:@"fallbackName"];
    [self.twoComponentFactory addAlias:alias forName:@"unhandled"];
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"namespace"];

    id<HUBComponent> const fallbackComponent = [HUBComponentMock new];
    NSDictionary * const components = @{@"fallbackName": fallbackComponent};
    HUBComponentFactoryMock *fallbackFactory = [[HUBComponentFactoryMock alloc] initWithComponents:components];

    [self.registry registerComponentFactory:fallbackFactory forNamespace:@"anotherNameSpace"];

    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace"
                                                                                                      name:@"unhandled"];

    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];

    XCTAssertEqual(fallbackComponent, [self.registry componentForModel:componentModel]);
}

- (void)testCanFallbackToAnotherNameInSameFactory
{
    HUBComponentIdentifier * const alias = [[HUBComponentIdentifier alloc] initWithNamespace:nil
                                                                                        name:@"A"];
    [self.twoComponentFactory addAlias:alias forName:@"nonexisting"];
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"testNamespace"];

    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"testNamespace"
                                                                                                      name:@"nonexisting"];

    HUBComponentModelImplementation * const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier];

    XCTAssertEqual(self.componentA, [self.registry componentForModel:componentModel]);
}

- (void)testAllComponentIdentifiers
{
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"namespaceA"];
    [self.registry registerComponentFactory:self.twoComponentFactory forNamespace:@"namespaceB"];

    NSArray * const expectedComponentIdentifiers = @[
            [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceA" name:@"A"],
            [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceA" name:@"B"],
            [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceB" name:@"A"],
            [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceB" name:@"B"]
    ];

    NSArray * const actualComponentIdentifiers = self.registry.allComponentIdentifiers;

    XCTAssertEqual(actualComponentIdentifiers.count, expectedComponentIdentifiers.count);

    for (HUBComponentIdentifier * const identifier in expectedComponentIdentifiers) {
        XCTAssertTrue([actualComponentIdentifiers containsObject:identifier]);
    }
}

#pragma mark - Utilities

- (HUBComponentModelImplementation *)mockedComponentModelWithComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier
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
