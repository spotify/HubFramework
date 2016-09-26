#import "HUBViewModelDiff.h"
#import "HUBIdentifier.h"
#import "HUBComponentModelImplementation.h"
#import "HUBViewModelImplementation.h"

#import <XCTest/XCTest.h>
#import <OCMockitoIOS/OCMockitoIOS.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

@interface HUBViewModelDiffTests : XCTestCase

@end

@implementation HUBViewModelDiffTests

- (void)setUp
{
    [super setUp];
}

- (id<HUBComponentModel>)createComponentModelWithIdentifier:(NSString *)identifier
                                                 customData:(nullable NSDictionary *)customData
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                  type:HUBComponentTypeBody
                                                                 index:0
                                                       groupIdentifier:nil
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:HUBComponentCategoryBanner
                                                                 title:@"title"
                                                              subtitle:@"subtitle"
                                                        accessoryTitle:nil
                                                       descriptionText:nil
                                                         mainImageData:nil
                                                   backgroundImageData:nil
                                                       customImageData:@{}
                                                                  icon:nil
                                                                target:nil
                                                              metadata:nil
                                                           loggingData:nil
                                                            customData:customData
                                                                parent:nil];
}

- (id<HUBViewModel>)createViewModelWithIdentifier:(NSString *)identifier components:(NSArray<id<HUBComponentModel>> *)components
{
    return [[HUBViewModelImplementation alloc] initWithIdentifier:identifier
                                               navigationBarTitle:@"Title"
                                             headerComponentModel:nil
                                              bodyComponentModels:components
                                           overlayComponentModels:@[]
                                                     extensionURL:nil
                                                       customData:@{@"custom": @"data"}];
}

- (void)testInsertions
{
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                            components:@[]];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.insertedIndices containsIndexesInRange:NSMakeRange(0, 4)]);
    XCTAssert(diff.reloadedIndices.count == 0);
    XCTAssert(diff.insertedIndices.count == 4);
    XCTAssert(diff.deletedIndices.count == 0);
}

- (void)testReloads
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                            components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" customData:@{@"test": @5}],
        [self createComponentModelWithIdentifier:@"component-2" customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" customData:@{@"test": @6}],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.reloadedIndices containsIndex:0]);
    XCTAssert([diff.reloadedIndices containsIndex:2]);

    XCTAssert(diff.reloadedIndices.count == 2);
    XCTAssert(diff.insertedIndices.count == 0);
    XCTAssert(diff.deletedIndices.count == 0);
}

- (void)testDeletions
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                            components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-2" customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.deletedIndices containsIndex:0]);
    XCTAssert([diff.deletedIndices containsIndex:2]);
    XCTAssert(diff.reloadedIndices.count == 0);
    XCTAssert(diff.insertedIndices.count == 0);
    XCTAssert(diff.deletedIndices.count == 2);
}

- (void)testComplexChangeSet
{
    NSArray<id<HUBComponentModel>> *firstComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" customData:nil],
        [self createComponentModelWithIdentifier:@"component-3" customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil],
        [self createComponentModelWithIdentifier:@"component-5" customData:nil],
        [self createComponentModelWithIdentifier:@"component-6" customData:nil],
        [self createComponentModelWithIdentifier:@"component-7" customData:nil],
        [self createComponentModelWithIdentifier:@"component-8" customData:nil],
        [self createComponentModelWithIdentifier:@"component-9" customData:nil],
        [self createComponentModelWithIdentifier:@"component-10" customData:nil]
    ];
    id<HUBViewModel> firstViewModel = [self createViewModelWithIdentifier:@"Test"
                                                            components:firstComponents];
    NSArray<id<HUBComponentModel>> *secondComponents = @[
        [self createComponentModelWithIdentifier:@"component-1" customData:nil],
        [self createComponentModelWithIdentifier:@"component-2" customData:@{@"test": @1}],
        [self createComponentModelWithIdentifier:@"component-30" customData:nil],
        [self createComponentModelWithIdentifier:@"component-4" customData:nil],
        [self createComponentModelWithIdentifier:@"component-5" customData:nil],
        [self createComponentModelWithIdentifier:@"component-6" customData:nil],
        [self createComponentModelWithIdentifier:@"component-7" customData:nil],
        [self createComponentModelWithIdentifier:@"component-9" customData:@{@"test": @2}],
        [self createComponentModelWithIdentifier:@"component-10" customData:nil],
        [self createComponentModelWithIdentifier:@"component-13" customData:nil]
    ];
    id<HUBViewModel> secondViewModel = [self createViewModelWithIdentifier:@"Test"
                                                                components:secondComponents];

    HUBViewModelDiff *diff = [HUBViewModelDiff diffFromViewModel:firstViewModel toViewModel:secondViewModel];
    XCTAssert([diff.deletedIndices containsIndex:2]);
    XCTAssert([diff.deletedIndices containsIndex:7]);
    XCTAssert([diff.insertedIndices containsIndex:2]);
    XCTAssert([diff.insertedIndices containsIndex:9]);
    XCTAssert([diff.reloadedIndices containsIndex:1]);
    XCTAssert([diff.reloadedIndices containsIndex:7]);
    XCTAssert(diff.reloadedIndices.count == 2);
    XCTAssert(diff.insertedIndices.count == 2);
    XCTAssert(diff.deletedIndices.count == 2);
}

@end
