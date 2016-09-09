#import <XCTest/XCTest.h>

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentCategories.h"

@interface HUBViewModelTests : XCTestCase

@end

@implementation HUBViewModelTests

- (void)testIdenticalInstancesAreEqual
{
    id<HUBViewModel>(^createViewModel)() = ^{
        id<HUBComponentModel> (^createComponentModel)() = ^{
            HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
            
            return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
                                                                         index:0
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
                                                                    customData:nil
                                                          childComponentModels:nil];
        };
        
        NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/viewmodelextension"];
        
        return [[HUBViewModelImplementation alloc] initWithIdentifier:@"identifier"
                                                   navigationBarTitle:@"title"
                                                 headerComponentModel:createComponentModel()
                                                  bodyComponentModels:@[createComponentModel()]
                                               overlayComponentModels:@[createComponentModel()]
                                                         extensionURL:extensionURL
                                                           customData:@{@"custom": @"data"}];
    };
    
    XCTAssertEqualObjects(createViewModel(), createViewModel());
}

- (void)testNonIdentificalInstancesAreNotEqual
{
    id<HUBViewModel>(^createViewModel)() = ^{
        id<HUBComponentModel> (^createComponentModel)() = ^{
            HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
            
            return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
                                                                         index:0
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
                                                                    customData:nil
                                                          childComponentModels:nil];
        };
        
        NSString * const title = [NSUUID UUID].UUIDString;
        NSURL * const extensionURL = [NSURL URLWithString:@"https://spotify.com/viewmodelextension"];
        
        return [[HUBViewModelImplementation alloc] initWithIdentifier:@"identifier"
                                                   navigationBarTitle:title
                                                 headerComponentModel:createComponentModel()
                                                  bodyComponentModels:@[createComponentModel()]
                                               overlayComponentModels:@[createComponentModel()]
                                                         extensionURL:extensionURL
                                                           customData:@{@"custom": @"data"}];
    };
    
    XCTAssertNotEqualObjects(createViewModel(), createViewModel());
}

@end
