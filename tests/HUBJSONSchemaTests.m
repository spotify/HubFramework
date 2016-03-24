#import <XCTest/XCTest.h>

#import "HUBJSONSchemaImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModel.h"

@interface HUBJSONSchemaTests : XCTestCase

@end

@implementation HUBJSONSchemaTests

- (void)testViewModelFromJSONDictionary
{
    NSString * const defaultComponentNamespace = @"default";
    NSString * const featureIdentifier = @"feature";
    
    HUBJSONSchemaImplementation * const schema = [[HUBJSONSchemaImplementation alloc] initWithDefaultComponentNamespace:defaultComponentNamespace];
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                   defaultComponentNamespace:defaultComponentNamespace];
    
    NSDictionary * const dictionary = @{
        @"body": @[
            @{
                @"component": @"namespace:name",
                @"title": @"A title"
            }
        ]
    };
    
    [builder addDataFromJSONDictionary:dictionary usingSchema:schema];
    
    id<HUBViewModel> const viewModelFromSchema = [schema viewModelFromJSONDictionary:dictionary featureIdentifier:featureIdentifier];
    id<HUBViewModel> const viewModelFromBuilder = [builder build];
    
    XCTAssertEqualObjects(viewModelFromSchema.featureIdentifier, viewModelFromBuilder.featureIdentifier);
    XCTAssertEqual(viewModelFromSchema.bodyComponentModels.count, viewModelFromBuilder.bodyComponentModels.count);
    XCTAssertEqualObjects([viewModelFromSchema.bodyComponentModels firstObject].title, [viewModelFromBuilder.bodyComponentModels firstObject].title);
}

@end
