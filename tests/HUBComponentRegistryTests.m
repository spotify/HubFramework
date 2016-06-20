#import <XCTest/XCTest.h>

#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentMock.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentFactoryMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"

static NSString * const DefaultNamespace = @"default";

@interface HUBComponentRegistryTests : XCTestCase

@property (nonatomic, strong) HUBComponentFallbackHandlerMock *componentFallbackHandler;
@property (nonatomic, strong) HUBComponentRegistryImplementation *registry;

@end

@implementation HUBComponentRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    self.componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    self.registry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:self.componentFallbackHandler];
}

#pragma mark - Tests

- (void)testRegisteringComponentFactory
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    id<HUBComponentModel> const componentModel = [self mockedComponentModelWithComponentIdentifier:componentIdentifier componentCategory:@"category"];
    HUBComponentMock * const component = [HUBComponentMock new];
    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:@{componentIdentifier.componentName: component}];
    
    [self.registry registerComponentFactory:factory forNamespace:componentIdentifier.componentNamespace];

    XCTAssertEqual([self.registry createComponentForModel:componentModel], component);
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

- (void)testUnregisteringComponentFactory
{
    NSString * const namespace = @"namespace";
    
    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    
    [self.registry registerComponentFactory:factory forNamespace:namespace];
    [self.registry unregisterComponentFactoryForNamespace:namespace];
    
    XCTAssertNoThrow([self.registry registerComponentFactory:factory forNamespace:namespace]);
}

- (void)testFallbackComponentCreatedForUnknownNamespace
{
    NSString * const componentCategory = @"category";
    HUBComponentMock * const fallbackComponent = [HUBComponentMock new];
    [self.componentFallbackHandler addFallbackComponent:fallbackComponent forCategory:componentCategory];
    
    HUBComponentIdentifier * const unknownNamespaceIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"unknown" name:@"name"];
    id<HUBComponentModel> const componentModel = [self mockedComponentModelWithComponentIdentifier:unknownNamespaceIdentifier
                                                                                 componentCategory:componentCategory];
    
    XCTAssertEqual([self.registry createComponentForModel:componentModel], fallbackComponent);
}

- (void)testFallbackComponentCreatedWhenFactoryReturnsNil
{
    NSString * const componentNamespace = @"namespace";
    NSString * const componentCategory = @"category";
    HUBComponentMock * const fallbackComponent = [HUBComponentMock new];
    [self.componentFallbackHandler addFallbackComponent:fallbackComponent forCategory:componentCategory];

    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    [self.registry registerComponentFactory:factory forNamespace:componentNamespace];
    
    HUBComponentIdentifier * const unknownNameIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentNamespace name:@"unknown"];
    id<HUBComponentModel> const componentModel = [self mockedComponentModelWithComponentIdentifier:unknownNameIdentifier
                                                                                 componentCategory:componentCategory];
    
    XCTAssertEqual([self.registry createComponentForModel:componentModel], fallbackComponent);
}

- (void)testFallbackComponentsForDifferentCategories
{
    NSString * const componentCategoryA = @"categoryA";
    HUBComponentMock * const fallbackComponentA = [HUBComponentMock new];
    [self.componentFallbackHandler addFallbackComponent:fallbackComponentA forCategory:componentCategoryA];
    
    NSString * const componentCategoryB = @"categoryB";
    HUBComponentMock * const fallbackComponentB = [HUBComponentMock new];
    [self.componentFallbackHandler addFallbackComponent:fallbackComponentB forCategory:componentCategoryB];
    
    NSString * const componentNamespace = @"namespace";
    
    HUBComponentFactoryMock * const factory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    [self.registry registerComponentFactory:factory forNamespace:componentNamespace];
    
    HUBComponentIdentifier * const unknownNameIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:componentNamespace name:@"unknown"];
    
    id<HUBComponentModel> const componentModelA = [self mockedComponentModelWithComponentIdentifier:unknownNameIdentifier
                                                                                  componentCategory:componentCategoryA];
    
    id<HUBComponentModel> const componentModelB = [self mockedComponentModelWithComponentIdentifier:unknownNameIdentifier
                                                                                  componentCategory:componentCategoryB];
    
    XCTAssertEqual([self.registry createComponentForModel:componentModelA], fallbackComponentA);
    XCTAssertEqual([self.registry createComponentForModel:componentModelB], fallbackComponentB);
}

- (void)testShowcaseableComponentIdentifiers
{
    HUBComponentFactoryMock * const factoryA = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    factoryA.showcaseableComponentNames = @[@"name1", @"name2"];
    [self.registry registerComponentFactory:factoryA forNamespace:@"namespaceA"];
    
    HUBComponentFactoryMock * const factoryB = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    factoryB.showcaseableComponentNames = @[@"name3", @"name4"];
    [self.registry registerComponentFactory:factoryB forNamespace:@"namespaceB"];
    
    NSArray * const componentIdentifiers = self.registry.showcaseableComponentIdentifiers;
    
    NSArray * const expectedComponentIdentifers = @[
        [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceA" name:@"name1"],
        [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceA" name:@"name2"],
        [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceB" name:@"name3"],
        [[HUBComponentIdentifier alloc] initWithNamespace:@"namespaceB" name:@"name4"]
    ];
    
    XCTAssertEqual(componentIdentifiers.count, expectedComponentIdentifers.count);
    
    for (HUBComponentIdentifier * const identifier in expectedComponentIdentifers) {
        XCTAssertTrue([componentIdentifiers containsObject:identifier]);
    }
}

#pragma mark - Utilities

- (id<HUBComponentModel>)mockedComponentModelWithComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier
                                                  componentCategory:(NSString *)componentCategory
{
    NSString * const identifier = [NSUUID UUID].UUIDString;

    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                 index:0
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:componentCategory
                                                                 title:nil
                                                              subtitle:nil
                                                        accessoryTitle:nil
                                                       descriptionText:nil
                                                         mainImageData:nil
                                                   backgroundImageData:nil
                                                       customImageData:@{}
                                                                  icon:nil
                                                             targetURL:nil
                                                targetInitialViewModel:nil
                                                              metadata:nil
                                                           loggingData:nil
                                                            customData:nil
                                                  childComponentModels:nil];
}

@end
