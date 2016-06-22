#import <XCTest/XCTest.h>

#import "HUBComponentRegistryImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentMock.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentFactoryMock.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBComponentDefaults+Testing.h"
#import "HUBComponentModelBuilder.h"
#import "HUBComponentShowcaseShapshotGenerator.h"
#import "HUBJSONSchemaRegistryImplementation.h"

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
    
    HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                                          iconImageResolver:nil];
    
    self.registry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:self.componentFallbackHandler
                                                                      componentDefaults:componentDefaults
                                                                     JSONSchemaRegistry:JSONSchemaRegistry
                                                                      iconImageResolver:nil];
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
    HUBComponentFactoryMock * const showcaseFactoryA = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    showcaseFactoryA.showcaseableComponentNames = @[@"name1", @"name2"];
    [self.registry registerComponentFactory:showcaseFactoryA forNamespace:@"namespaceA"];
    
    HUBComponentFactoryMock * const showcaseFactoryB = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    showcaseFactoryB.showcaseableComponentNames = @[@"name3", @"name4"];
    [self.registry registerComponentFactory:showcaseFactoryB forNamespace:@"namespaceB"];
    
    HUBComponentFactoryMock * const noShowcaseFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    [self.registry registerComponentFactory:noShowcaseFactory forNamespace:@"namespaceC"];
    
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

- (void)testShowcaseNameForComponentIdentifier
{
    HUBComponentFactoryMock * const showcaseFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    showcaseFactory.showcaseNamesForComponentNames = @{
        @"a": @"Component A",
        @"b": @"Component B"
    };
    
    [self.registry registerComponentFactory:showcaseFactory forNamespace:@"showcase"];
    
    HUBComponentFactoryMock * const noShowcaseFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{}];
    [self.registry registerComponentFactory:noShowcaseFactory forNamespace:@"noShowcase"];
    
    HUBComponentIdentifier * const componentIdentifierA = [[HUBComponentIdentifier alloc] initWithNamespace:@"showcase" name:@"a"];
    XCTAssertEqualObjects([self.registry showcaseNameForComponentIdentifier:componentIdentifierA], @"Component A");
    
    HUBComponentIdentifier * const componentIdentifierB = [[HUBComponentIdentifier alloc] initWithNamespace:@"showcase" name:@"b"];
    XCTAssertEqualObjects([self.registry showcaseNameForComponentIdentifier:componentIdentifierB], @"Component B");
    
    HUBComponentIdentifier * const noShowcaseComponentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"noShowcase" name:@"name"];
    XCTAssertNil([self.registry showcaseNameForComponentIdentifier:noShowcaseComponentIdentifier]);
}

- (void)testShowcaseComponentSnapshotting
{
    HUBComponentMock * const component = [HUBComponentMock new];
    component.view = [[UIView alloc] initWithFrame:CGRectZero];
    component.preferredViewSize = CGSizeMake(200, 200);
    
    HUBComponentFactoryMock * const componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        @"name": component
    }];
    
    [self.registry registerComponentFactory:componentFactory forNamespace:@"namespace"];
    
    id<HUBComponentModelBuilder, HUBComponentShowcaseSnapshotGenerator> const componentModelBuilder = [self.registry createShowcaseSnapshotComponentModelBuilder];
    componentModelBuilder.componentNamespace = @"namespace";
    componentModelBuilder.componentName = @"name";
    
    UIImage * const snapshotImage = [componentModelBuilder generateShowcaseSnapshotForContainerViewSize:CGSizeZero];
    XCTAssertTrue(CGSizeEqualToSize(snapshotImage.size, CGSizeMake(200, 200)));
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
