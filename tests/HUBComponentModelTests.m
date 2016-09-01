#import <XCTest/XCTest.h>

#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBIconImplementation.h"

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

- (void)testIdenticalInstancesAreEqual
{
    id<HUBComponentModel> (^createComponentModel)() = ^() {
        HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
        NSURL * const targetURL = [NSURL URLWithString:@"spotify:hub:framework"];
        
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
        
        return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
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
                                                                 targetURL:targetURL
                                                    targetInitialViewModel:nil
                                                                  metadata:@{@"meta": @"data"}
                                                               loggingData:@{@"logging": @"data"}
                                                                customData:@{@"custom" : @"data"}
                                                      childComponentModels:@[]];
    };
    
    XCTAssertEqualObjects(createComponentModel(), createComponentModel());
}

- (void)testNonIdenticalInstancesAreNotEqual
{
    id<HUBComponentModel> (^createComponentModel)() = ^() {
        NSString * const identifier = [NSUUID UUID].UUIDString;
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
                                                      childComponentModels:@[]];
    };
    
    XCTAssertNotEqualObjects(createComponentModel(), createComponentModel());
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
