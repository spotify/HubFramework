#import <XCTest/XCTest.h>

#import "HUBJSONSchemaImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentModel.h"
#import "HUBComponentDefaults+Testing.h"

@interface HUBJSONSchemaTests : XCTestCase

@end

@implementation HUBJSONSchemaTests

- (void)testViewModelFromJSONDictionary
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    NSString * const featureIdentifier = @"feature";
    
    HUBJSONSchemaImplementation * const schema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults];
    
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                                  JSONSchema:schema
                                                                                                           componentDefaults:componentDefaults];
    
    NSDictionary * const dictionary = @{
        @"body": @[
            @{
                @"component": @"namespace:name",
                @"title": @"A title"
            }
        ]
    };
    
    [builder addDataFromJSONDictionary:dictionary];
    
    id<HUBViewModel> const viewModelFromSchema = [schema viewModelFromJSONDictionary:dictionary featureIdentifier:featureIdentifier];
    id<HUBViewModel> const viewModelFromBuilder = [builder build];
    
    XCTAssertEqualObjects(viewModelFromSchema.featureIdentifier, viewModelFromBuilder.featureIdentifier);
    XCTAssertEqual(viewModelFromSchema.bodyComponentModels.count, viewModelFromBuilder.bodyComponentModels.count);
    XCTAssertEqualObjects([viewModelFromSchema.bodyComponentModels firstObject].title, [viewModelFromBuilder.bodyComponentModels firstObject].title);
}

- (void)testCopy
{
    HUBComponentDefaults * const componentDefaults = [HUBComponentDefaults defaultsForTesting];
    id<HUBJSONSchema> const schema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults];
    id<HUBJSONSchema> const copy = [schema copy];
    
    // Assert that the copied sub schemas are not the same instance as the original ones
    XCTAssertNotEqual(schema.viewModelSchema, copy.viewModelSchema);
    XCTAssertNotEqual(schema.componentModelSchema, copy.componentModelSchema);
    XCTAssertNotEqual(schema.componentImageDataSchema, copy.componentImageDataSchema);
}

@end
