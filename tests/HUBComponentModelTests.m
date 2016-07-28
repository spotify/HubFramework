#import <XCTest/XCTest.h>

#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"

@interface HUBComponentModelTests : XCTestCase

@end

@implementation HUBComponentModelTests

- (void)testChildComponentModelAtIndex
{
    NSArray * const childModels = @[
        [self createComponentModelWithIdentifier:@"child1" childComponentModels:nil],
        [self createComponentModelWithIdentifier:@"child2" childComponentModels:nil]
    ];
    
    HUBComponentModelImplementation * const model = [self createComponentModelWithIdentifier:@"id"
                                                                        childComponentModels:childModels];
    
    XCTAssertEqual([model childComponentModelAtIndex:0], childModels[0]);
    XCTAssertEqual([model childComponentModelAtIndex:1], childModels[1]);
    XCTAssertNil([model childComponentModelAtIndex:2]);
}

#pragma mark - Utilities

- (HUBComponentModelImplementation *)createComponentModelWithIdentifier:(NSString *)identifier
                                                   childComponentModels:(nullable NSArray<HUBComponentModelImplementation *> *)childComponentModels
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                 index:0
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:HUBComponentCategoryRow
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
                                                  childComponentModels:childComponentModels];
}

@end
