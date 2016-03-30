#import "HUBJSONSchemaImplementation.h"

#import "HUBViewModelJSONSchemaImplementation.h"
#import "HUBComponentModelJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchemaImplementation.h"
#import "HUBMutableJSONPathImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBJSONSchemaImplementation ()

@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;

@end

@implementation HUBJSONSchemaImplementation

@synthesize viewModelSchema = _viewModelSchema;
@synthesize componentModelSchema = _componentModelSchema;
@synthesize componentImageDataSchema = _componentImageDataSchema;

#pragma mark - Initializers

- (instancetype)initWithDefaultComponentNamespace:(NSString *)defaultComponentNamespace
{
    return [self initWithViewModelSchema:[HUBViewModelJSONSchemaImplementation new]
                    componentModelSchema:[HUBComponentModelJSONSchemaImplementation new]
                componentImageDataSchema:[HUBComponentImageDataJSONSchemaImplementation new]
               defaultComponentNamespace:defaultComponentNamespace];
}

- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
{
    self = [super init];
    
    if (self) {
        _viewModelSchema = viewModelSchema;
        _componentModelSchema = componentModelSchema;
        _componentImageDataSchema = componentImageDataSchema;
        _defaultComponentNamespace = [defaultComponentNamespace copy];
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
                                              defaultComponentNamespace:self.defaultComponentNamespace];
}

- (id<HUBViewModel>)viewModelFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary featureIdentifier:(NSString *)featureIdentifier
{
    HUBViewModelBuilderImplementation * const builder = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:featureIdentifier
                                                                                                                  JSONSchema:self
                                                                                                   defaultComponentNamespace:self.defaultComponentNamespace];
    
    [builder addDataFromJSONDictionary:dictionary];
    return [builder build];
}

@end

NS_ASSUME_NONNULL_END
