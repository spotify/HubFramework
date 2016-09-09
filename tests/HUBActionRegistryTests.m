#import <XCTest/XCTest.h>

#import "HUBActionRegistryImplementation.h"
#import "HUBActionFactoryMock.h"
#import "HUBActionMock.h"
#import "HUBActionContextImplementation+Testing.h"

@interface HUBActionRegistryTests : XCTestCase

@property (nonatomic, strong) HUBActionRegistryImplementation *actionRegistry;

@end

@implementation HUBActionRegistryTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    self.actionRegistry = [HUBActionRegistryImplementation new];
}

#pragma mark - Tests

- (void)testRegisteringFactoryAndCreatingAction
{
    HUBActionMock * const action = [[HUBActionMock alloc] initWithBlock:nil];
    HUBActionFactoryMock * const factory = [[HUBActionFactoryMock alloc] initWithActions:@{@"name": action}];
    [self.actionRegistry registerActionFactory:factory forNamespace:@"namespace"];
    
    id<HUBActionContext> const context = [HUBActionContextImplementation contextForTestingWithActionNamespace:@"namespace" name:@"name"];
    XCTAssertEqual([self.actionRegistry actionForContext:context], action);
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
