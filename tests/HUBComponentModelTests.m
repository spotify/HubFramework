#import <XCTest/XCTest.h>

#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBComponentTargetImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBIconImplementation.h"
#import "HUBViewModelImplementation.h"

@interface HUBComponentModelTests : XCTestCase

@end

@implementation HUBComponentModelTests

- (void)testChildComponentModelAtIndex
{
    NSArray * const childModels = @[
        [self createComponentModelWithIdentifier:@"child1" index:0],
        [self createComponentModelWithIdentifier:@"child2" index:1]
    ];
    
    HUBComponentModelImplementation * const model = [self createComponentModelWithIdentifier:@"id" index:0];
    model.children = childModels;
    
    XCTAssertEqual([model childComponentModelAtIndex:0], childModels[0]);
    XCTAssertEqual([model childComponentModelAtIndex:1], childModels[1]);
    XCTAssertNil([model childComponentModelAtIndex:2]);
}

- (void)testIdenticalInstancesAreEqual
{
    id<HUBComponentModel> (^createComponentModel)() = ^() {
        HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        
        NSURL * const mainImageURL = [NSURL URLWithString:@"https://image.com/main.jpg"];
        id<HUBComponentImageData> const mainImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                                                   type:HUBComponentImageTypeMain
                                                                                                                  style:HUBComponentImageStyleRectangular
                                                                                                                    URL:mainImageURL
                                                                                                        placeholderIcon:nil
                                                                                                             localImage:nil];
        
        NSURL * const backgroundImageURL = [NSURL URLWithString:@"https://image.com/main.jpg"];
        id<HUBComponentImageData> const backgroundImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                                                         type:HUBComponentImageTypeBackground
                                                                                                                        style:HUBComponentImageStyleRectangular
                                                                                                                          URL:backgroundImageURL
                                                                                                              placeholderIcon:nil
                                                                                                                   localImage:nil];
        
        NSURL * const customImageURL = [NSURL URLWithString:@"https://image.com/custom.jpg"];
        id<HUBComponentImageData> const customImageData = [[HUBComponentImageDataImplementation alloc] initWithIdentifier:nil
                                                                                                                     type:HUBComponentImageTypeCustom
                                                                                                                    style:HUBComponentImageStyleRectangular
                                                                                                                      URL:customImageURL
                                                                                                          placeholderIcon:nil
                                                                                                               localImage:nil];
        
        NSURL * const targetURI = [NSURL URLWithString:@"spotify:hub:framework"];
        HUBViewModelImplementation * const targetInitialViewModel = [[HUBViewModelImplementation alloc] initWithIdentifier:nil
                                                                                                        navigationBarTitle:nil
                                                                                                      headerComponentModel:nil
                                                                                                       bodyComponentModels:@[]
                                                                                                    overlayComponentModels:@[]
                                                                                                              extensionURL:nil
                                                                                                                customData:nil];
        
        id<HUBComponentTarget> const target = [[HUBComponentTargetImplementation alloc] initWithURI:targetURI
                                                                                   initialViewModel:targetInitialViewModel
                                                                                         customData:@{@"custom": @"data"}];
        
        return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
                                                                      type:HUBComponentTypeBody
                                                                     index:0
                                                       componentIdentifier:componentIdentifier
                                                         componentCategory:HUBComponentCategoryRow
                                                                     title:@"Title"
                                                                  subtitle:@"Subtitle"
                                                            accessoryTitle:@"Accessory title"
                                                           descriptionText:@"Description text"
                                                             mainImageData:mainImageData
                                                       backgroundImageData:backgroundImageData
                                                           customImageData:@{@"custom": customImageData}
                                                                      icon:nil
                                                                    target:target
                                                                  metadata:@{@"meta": @"data"}
                                                               loggingData:@{@"logging": @"data"}
                                                                customData:@{@"custom": @"data"}
                                                                    parent:nil];
    };
    
    XCTAssertEqualObjects(createComponentModel(), createComponentModel());
}

- (void)testNonIdenticalInstancesAreNotEqual
{
    id<HUBComponentModel> (^createComponentModel)() = ^() {
        NSString * const identifier = [NSUUID UUID].UUIDString;
        HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        
        return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                      type:HUBComponentTypeBody
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
                                                                    target:nil
                                                                  metadata:nil
                                                               loggingData:nil
                                                                customData:nil
                                                                    parent:nil];
    };
    
    XCTAssertNotEqualObjects(createComponentModel(), createComponentModel());
}

- (void)testChildWithIdentifier
{
    HUBComponentModelImplementation * const parent = [self createComponentModelWithIdentifier:@"parent" index:0];
    HUBComponentModelImplementation * const childA = [self createComponentModelWithIdentifier:@"childA" index:0];
    HUBComponentModelImplementation * const childB = [self createComponentModelWithIdentifier:@"childB" index:1];
    HUBComponentModelImplementation * const childC = [self createComponentModelWithIdentifier:@"childC" index:2];
    parent.children = @[childA, childB, childC];
    
    XCTAssertEqual([parent childWithIdentifier:@"childA"], childA);
    XCTAssertEqual([parent childWithIdentifier:@"childB"], childB);
    XCTAssertEqual([parent childWithIdentifier:@"childC"], childC);
    XCTAssertNil([parent childWithIdentifier:@"noChild"]);
}

#pragma mark - Utilities

- (HUBComponentModelImplementation *)createComponentModelWithIdentifier:(NSString *)identifier index:(NSUInteger)index
{
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    HUBComponentTargetImplementation * const target = [[HUBComponentTargetImplementation alloc] initWithURI:nil
                                                                                           initialViewModel:nil
                                                                                                 customData:nil];
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:identifier
                                                                  type:HUBComponentTypeBody
                                                                 index:index
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
                                                                target:target
                                                              metadata:nil
                                                           loggingData:nil
                                                            customData:nil
                                                                parent:nil];
}

@end
