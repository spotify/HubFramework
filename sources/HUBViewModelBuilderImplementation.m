#import "HUBViewModelBuilderImplementation.h"

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelJSONSchema.h"
#import "HUBComponentModelJSONSchema.h"
#import "HUBJSONPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelBuilderImplementation ()

@property (nonatomic, strong, readonly) HUBComponentModelBuilderImplementation *headerComponentModelBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *bodyComponentModelBuilders;

@end

@implementation HUBViewModelBuilderImplementation

@synthesize viewIdentifier = _viewIdentifier;
@synthesize featureIdentifier = _featureIdentifier;
@synthesize entityIdentifier = _entityIdentifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
{
    NSParameterAssert(featureIdentifier != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _viewIdentifier = [NSUUID UUID].UUIDString;
    _featureIdentifier = featureIdentifier;
    _headerComponentModelBuilderImplementation = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"header" featureIdentifier:featureIdentifier];
    _bodyComponentModelBuilders = [NSMutableDictionary new];
    
    return self;
}

#pragma mark - HUBViewModelBuilder

- (id<HUBComponentModelBuilder>)headerComponentModelBuilder
{
    return self.headerComponentModelBuilderImplementation;
}

- (BOOL)builderExistsForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return [self.bodyComponentModelBuilders objectForKey:identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForBodyComponentModelWithIdentifier:identifier];
}

#pragma mark - HUBJSONCompatibleBuilder

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary usingSchema:(id<HUBJSONSchema>)schema
{
    id<HUBViewModelJSONSchema> const viewModelSchema = schema.viewModelSchema;
    
    NSString * const viewIdentifier = [viewModelSchema.identifierPath stringFromJSONDictionary:dictionary];
    
    if (viewIdentifier != nil) {
        self.viewIdentifier = viewIdentifier;
    }
    
    NSString * const featureIdentifier = [viewModelSchema.featureIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (featureIdentifier != nil) {
        self.featureIdentifier = featureIdentifier;
    }
    
    self.entityIdentifier = [viewModelSchema.entityIdentifierPath stringFromJSONDictionary:dictionary];
    self.navigationBarTitle = [viewModelSchema.navigationBarTitlePath stringFromJSONDictionary:dictionary];
    self.extensionURL = [viewModelSchema.extensionURLPath URLFromJSONDictionary:dictionary];
    self.customData = [viewModelSchema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
    NSDictionary * const headerComponentModelDictionary = [viewModelSchema.headerComponentModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (headerComponentModelDictionary != nil) {
        [self.headerComponentModelBuilderImplementation addDataFromJSONDictionary:headerComponentModelDictionary usingSchema:schema];
    }
    
    NSArray * const bodyComponentModelDictionaries = [viewModelSchema.bodyComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const componentModelDictionary in bodyComponentModelDictionaries) {
        NSString * componentIdentifier = [schema.componentModelSchema.identifierPath stringFromJSONDictionary:componentModelDictionary];
        
        if (componentIdentifier == nil) {
            componentIdentifier = [NSString stringWithFormat:@"UnknownComponent:%@", [NSUUID UUID].UUIDString];
        }
        
        HUBComponentModelBuilderImplementation * const builder = [self getOrCreateBuilderForBodyComponentModelWithIdentifier:componentIdentifier];
        [builder addDataFromJSONDictionary:componentModelDictionary usingSchema:schema];
    }
}

#pragma mark - API

- (HUBViewModelImplementation *)build
{
    HUBComponentModelImplementation *headerComponentModel;
    
    if (self.headerComponentModelBuilder.componentIdentifier != nil) {
        headerComponentModel = [self.headerComponentModelBuilderImplementation build];
    } else {
        headerComponentModel = nil;
    }
    
    NSMutableArray * const bodyComponentModels = [NSMutableArray new];
    
    for (HUBComponentModelBuilderImplementation * const builder in self.bodyComponentModelBuilders.allValues) {
        [bodyComponentModels addObject:[builder build]];
    }
    
    return [[HUBViewModelImplementation alloc] initWithIdentifier:self.viewIdentifier
                                                featureIdentifier:self.featureIdentifier
                                                 entityIdentifier:self.entityIdentifier
                                               navigationBarTitle:self.navigationBarTitle
                                             headerComponentModel:headerComponentModel
                                              bodyComponentModels:[bodyComponentModels copy]
                                                     extensionURL:self.extensionURL
                                                       customData:[self.customData copy]];
}

#pragma mark - Private utilities

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = [self.bodyComponentModelBuilders objectForKey:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                                                                      featureIdentifier:self.featureIdentifier];
    
    [self.bodyComponentModelBuilders setObject:newBuilder forKey:identifier];
    return newBuilder;
}

@end

NS_ASSUME_NONNULL_END
