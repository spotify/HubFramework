#import "HUBComponentTargetBuilderImplementation.h"

#import "HUBViewModelBuilderImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentTargetJSONSchema.h"
#import "HUBComponentTargetImplementation.h"

#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentTargetBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *initialViewModelBuilderImplementation;

@end

@implementation HUBComponentTargetBuilderImplementation

@synthesize URI = _URI;
@synthesize customData = _customData;

#pragma mark - Initializer

- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
    }
    
    return self;
}

#pragma mark - API

- (id<HUBComponentTarget>)build
{
    id<HUBViewModel> const initialViewModel = [self.initialViewModelBuilderImplementation build];
    
    return [[HUBComponentTargetImplementation alloc] initWithURI:self.URI
                                                initialViewModel:initialViewModel
                                                      customData:self.customData];
}

#pragma mark - HUBComponentTargetBuilder

- (id<HUBViewModelBuilder>)initialViewModelBuilder
{
    return [self getOrCreateInitialViewModelBuilder];
}

#pragma mark - HUBJSONCompatibleBuilder

- (nullable NSError *)addJSONData:(NSData *)JSONData
{
    return HUBAddJSONDataToBuilder(JSONData, self);
}

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBComponentTargetJSONSchema> const schema = self.JSONSchema.componentTargetSchema;
    
    NSURL * const URI = [schema.URIPath URLFromJSONDictionary:dictionary];
    
    if (URI != nil) {
        self.URI = URI;
    }
    
    NSDictionary * const initialViewModelDictionary = [schema.initialViewModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (initialViewModelDictionary != nil) {
        [[self getOrCreateInitialViewModelBuilder] addDataFromJSONDictionary:initialViewModelDictionary];
    }
    
    NSDictionary * const customData = [schema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (customData != nil) {
        self.customData = customData;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBComponentTargetBuilderImplementation * const copy = [[HUBComponentTargetBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                             componentDefaults:self.componentDefaults
                                                                                                             iconImageResolver:self.iconImageResolver];
    
    copy.URI = self.URI;
    copy.initialViewModelBuilderImplementation = [self.initialViewModelBuilderImplementation copy];
    copy.customData = self.customData;
    
    return copy;
}

#pragma mark - Private utilities

- (HUBViewModelBuilderImplementation *)getOrCreateInitialViewModelBuilder
{
    if (self.initialViewModelBuilderImplementation != nil) {
        return (HUBViewModelBuilderImplementation *)self.initialViewModelBuilderImplementation;
    }
    
    HUBViewModelBuilderImplementation * const initialViewModelBuilderImplementation = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                                                  componentDefaults:self.componentDefaults
                                                                                                                                  iconImageResolver:self.iconImageResolver];
    
    self.initialViewModelBuilderImplementation = initialViewModelBuilderImplementation;
    return initialViewModelBuilderImplementation;
}

@end

NS_ASSUME_NONNULL_END
