#import <XCTest/XCTest.h>

#import "HUBActionRegistryImplementation.h"
#import "HUBActionFactoryMock.h"
#import "HUBActionMock.h"
#import "HUBIdentifier.h"

@interface HUBActionRegistryTests : XCTestCase

@property (nonatomic, strong) HUBActionRegistryImplementation *actionRegistry;

@end

@implementation HUBActionRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.actionRegistry = [HUBActionRegistryImplementation registryWithDefaultSelectionAction];
}

#pragma mark - Tests

- (void)testRegisteringFactoryAndCreatingAction
{
    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    
    HUBActionMock * const action = [[HUBActionMock alloc] initWithBlock:nil];
    HUBActionFactoryMock * const factory = [[HUBActionFactoryMock alloc] initWithActions:@{actionIdentifier.namePart: action}];
    [self.actionRegistry registerActionFactory:factory forNamespace:actionIdentifier.namespacePart];
    
    XCTAssertEqual([self.actionRegistry createCustomActionForIdentifier:actionIdentifier], action);
}

- (void)testRegisteringAlreadyRegisteredFactoryThrows
{
    HUBActionFactoryMock * const factoryA = [[HUBActionFactoryMock alloc] initWithActions:nil];
    [self.actionRegistry registerActionFactory:factoryA forNamespace:@"namespace"];
    
    HUBActionFactoryMock * const factoryB = [[HUBActionFactoryMock alloc] initWithActions:nil];
    XCTAssertThrows([self.actionRegistry registerActionFactory:factoryB forNamespace:@"namespace"]);
}

- (void)testUnregisteringFactory
{
    HUBActionFactoryMock * const factoryA = [[HUBActionFactoryMock alloc] initWithActions:nil];
    [self.actionRegistry registerActionFactory:factoryA forNamespace:@"namespace"];
    
    [self.actionRegistry unregisterActionFactoryForNamespace:@"namespace"];
    
    HUBActionFactoryMock * const factoryB = [[HUBActionFactoryMock alloc] initWithActions:nil];
    XCTAssertNoThrow([self.actionRegistry registerActionFactory:factoryB forNamespace:@"namespace"]);
}

@end
