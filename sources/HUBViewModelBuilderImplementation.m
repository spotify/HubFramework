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
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *bodyComponentIdentifierOrder;

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
    _featureIdentifier = [featureIdentifier copy];
    _headerComponentModelBuilderImplementation = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:@"header" featureIdentifier:featureIdentifier];
    _bodyComponentModelBuilders = [NSMutableDictionary new];
    _bodyComponentIdentifierOrder = [NSMutableArray new];
    
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
        [self addDataFromBodyComponentModelJSONDictionary:componentModelDictionary usingSchema:schema];
    }
}

#pragma mark - API

- (BOOL)isEmpty
{
    if (![self headerComponentModelBuilderIsConsideredEmpty]) {
        return NO;
    }
    
    if (self.bodyComponentModelBuilders.count > 0) {
        return NO;
    }
    
    return YES;
}

- (void)addDataFromJSONArray:(NSArray<NSObject *> *)array usingSchema:(id<HUBJSONSchema>)schema
{
    for (NSObject * const object in array) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [self addDataFromBodyComponentModelJSONDictionary:(NSDictionary *)object usingSchema:schema];
        }
    }
}

- (void)addDataFromBodyComponentModelJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary usingSchema:(id<HUBJSONSchema>)schema
{
    NSString * const identifier = [schema.componentModelSchema.identifierPath stringFromJSONDictionary:dictionary];
    HUBComponentModelBuilderImplementation * const builder = [self getOrCreateBuilderForBodyComponentModelWithIdentifier:identifier];
    [builder addDataFromJSONDictionary:dictionary usingSchema:schema];
}

- (HUBViewModelImplementation *)build
{
    HUBComponentModelImplementation *headerComponentModel;
    
    if (![self headerComponentModelBuilderIsConsideredEmpty]) {
        headerComponentModel = [self.headerComponentModelBuilderImplementation build];
    } else {
        headerComponentModel = nil;
    }
    
    NSArray * const bodyComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.bodyComponentModelBuilders
                                                                                                    identifierOrder:self.bodyComponentIdentifierOrder];
    
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

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForBodyComponentModelWithIdentifier:(nullable NSString *)identifier
{
    if (identifier != nil) {
        HUBComponentModelBuilderImplementation * const existingBuilder = [self.bodyComponentModelBuilders objectForKey:identifier];
        
        if (existingBuilder != nil) {
            return existingBuilder;
        }
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                                                                      featureIdentifier:self.featureIdentifier];
    
    [self.bodyComponentModelBuilders setObject:newBuilder forKey:newBuilder.modelIdentifier];
    [self.bodyComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (BOOL)headerComponentModelBuilderIsConsideredEmpty
{
    return self.headerComponentModelBuilder.componentIdentifier == nil;
}

@end

NS_ASSUME_NONNULL_END
