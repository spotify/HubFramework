#import "HUBJSONSchemaImplementation.h"

#import "HUBViewModelJSONSchemaImplementation.h"
#import "HUBComponentModelJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchemaImplementation.h"
#import "HUBMutableJSONPathImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONSchemaImplementation ()

@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;

@end

@implementation HUBJSONSchemaImplementation

@synthesize viewModelSchema = _viewModelSchema;
@synthesize componentModelSchema = _componentModelSchema;
@synthesize componentImageDataSchema = _componentImageDataSchema;

#pragma mark - Initializers

- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults
{
    return [self initWithViewModelSchema:[HUBViewModelJSONSchemaImplementation new]
                    componentModelSchema:[HUBComponentModelJSONSchemaImplementation new]
                componentImageDataSchema:[HUBComponentImageDataJSONSchemaImplementation new]
                       componentDefaults:componentDefaults];
}

- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
{
    self = [super init];
    
    if (self) {
        _viewModelSchema = viewModelSchema;
        _componentModelSchema = componentModelSchema;
        _componentImageDataSchema = componentImageDataSchema;
        _componentDefaults = componentDefaults;
    }
    
    return self;
}

#pragma mark - HUBJSONSchema

- (id<HUBMutableJSONPath>)createNewPath
{
    return [[HUBMutableJSONPathImplementation alloc] initWithParsingOperations:@[]];
}

- (id)copy
{
    return [[HUBJSONSchemaImplementation alloc] initWithViewModelSchema:[self.viewModelSchema copy]
                                                   componentModelSchema:[self.componentModelSchema copy]
                                               componentImageDataSchema:[self.componentImageDataSchema copy]
                                                      componentDefaults:self.componentDefaults];
}

- (id<HUBViewModel>)viewModelFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary featureIdentifier:(NSString *)featureIdentifier
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                                  JSONSchema:self
                                                                                                           componentDefaults:self.componentDefaults];
    
    [builder addDataFromJSONDictionary:dictionary];
    return [builder build];
}

@end

NS_ASSUME_NONNULL_END
