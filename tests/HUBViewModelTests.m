#import <XCTest/XCTest.h>

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"
#import "HUBComponentCategories.h"

@interface HUBViewModelTests : XCTestCase

@end

@implementation HUBViewModelTests

- (void)testIdenticalInstancesAreEqual
{
    id<HUBViewModel>(^createViewModel)() = ^{
        id<HUBComponentModel> (^createComponentModel)() = ^{
            HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
            
            return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
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
                                                                    customData:nil
                                                                        parent:nil];
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
            HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
            
            return [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
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
                                                                    customData:nil
                                                                        parent:nil];
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
