#import "HUBJSONSchemaImplementation.h"

#import "HUBViewModelJSONSchemaImplementation.h"
#import "HUBComponentModelJSONSchemaImplementation.h"
#import "HUBComponentImageDataJSONSchemaImplementation.h"
#import "HUBMutableJSONPathImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBJSONSchemaImplementation

@synthesize viewModelSchema = _viewModelSchema;
@synthesize componentModelSchema = _componentModelSchema;
@synthesize componentImageDataSchema = _componentImageDataSchema;

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithViewModelSchema:[HUBViewModelJSONSchemaImplementation new]
                    componentModelSchema:[HUBComponentModelJSONSchemaImplementation new]
                componentImageDataSchema:[HUBComponentImageDataJSONSchemaImplementation new]];
}

- (instancetype)initWithViewModelSchema:(id<HUBViewModelJSONSchema>)viewModelSchema
                   componentModelSchema:(id<HUBComponentModelJSONSchema>)componentModelSchema
               componentImageDataSchema:(id<HUBComponentImageDataJSONSchema>)componentImageDataSchema
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _viewModelSchema = viewModelSchema;
    _componentModelSchema = componentModelSchema;
    _componentImageDataSchema = componentImageDataSchema;
    
    return self;
}

#pragma mark - HUBJSONSchema

- (id<HUBMutableJSONPath>)createNewPath
{
    return [[HUBMutableJSONPathImplementation alloc] initWithParsingOperations:@[]];
}

- (id<HUBJSONSchema>)copy
{
    return [[HUBJSONSchemaImplementation alloc] initWithViewModelSchema:[self.viewModelSchema copy]
                                                   componentModelSchema:[self.componentModelSchema copy]
                                               componentImageDataSchema:[self.componentImageDataSchema copy]];
}

@end

NS_ASSUME_NONNULL_END
