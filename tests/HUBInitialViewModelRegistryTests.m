#import <XCTest/XCTest.h>

#import "HUBInitialViewModelRegistry.h"
#import "HUBViewModelImplementation.h"

@interface HUBInitialViewModelRegistryTests : XCTestCase

@property (nonatomic, strong) HUBInitialViewModelRegistry *registry;

@end

@implementation HUBInitialViewModelRegistryTests

- (void)setUp
{
    [super setUp];
    self.registry = [HUBInitialViewModelRegistry new];
}

- (void)testRegisteringRetrievingAndRemovingInitialViewModel
{
    id<HUBViewModel> const viewModel = [[HUBViewModelImplementation alloc] initWithIdentifier:@"id"
                                                                           navigationBarTitle:nil
                                                                         headerComponentModel:nil
                                                                          bodyComponentModels:@[]
                                                                       overlayComponentModels:@[]
                                                                                 extensionURL:nil
                                                                                   customData:nil];
    
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    [self.registry registerInitialViewModel:viewModel forViewURI:viewURI];
    
    XCTAssertEqual([self.registry initialViewModelForViewURI:viewURI], viewModel);
    
    NSURL * const unknownViewURI = [NSURL URLWithString:@"spotify:some:other:uri"];
    XCTAssertNil([self.registry initialViewModelForViewURI:unknownViewURI]);
    
    [self.registry removeInitialViewModelForViewURI:viewURI];
    XCTAssertNil([self.registry initialViewModelForViewURI:viewURI]);
}

@end
