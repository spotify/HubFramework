#import "HUBViewModelBuilderImplementation.h"

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentIdentifier.h"
#import "HUBJSONSchema.h"
#import "HUBViewModelJSONSchema.h"
#import "HUBComponentModelJSONSchema.h"
#import "HUBJSONPath.h"
#import "HUBUtilities.h"
#import "HUBImplementationMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewModelBuilderImplementation () <HUBModificationDelegate>

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, nullable) HUBComponentModelBuilderImplementation *headerComponentModelBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *bodyComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *overlayComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *bodyComponentIdentifierOrder;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *overlayComponentIdentifierOrder;

@end

@implementation HUBViewModelBuilderImplementation

#pragma mark - Property synthesization

@synthesize viewIdentifier = _viewIdentifier;
@synthesize featureIdentifier = _featureIdentifier;
@synthesize navigationBarTitle = _navigationBarTitle;
@synthesize extensionURL = _extensionURL;
@synthesize customData = _customData;
@synthesize modificationDelegate = _modificationDelegate;

#pragma mark - Modification tracking

HUB_TRACK_MODIFICATIONS(_viewIdentifier, setViewIdentifier:, nullable)
HUB_TRACK_MODIFICATIONS(_featureIdentifier, setFeatureIdentifier:, nonnull)
HUB_TRACK_MODIFICATIONS(_navigationBarTitle, setNavigationBarTitle:, nullable)
HUB_TRACK_MODIFICATIONS(_extensionURL, setExtensionURL:, nullable)
HUB_TRACK_MODIFICATIONS(_customData, setCustomData:, nullable)

#pragma mark - Initializer

- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                               JSONSchema:(id<HUBJSONSchema>)JSONSchema
                        componentDefaults:(HUBComponentDefaults *)componentDefaults
                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
        _featureIdentifier = [featureIdentifier copy];
        _bodyComponentModelBuilders = [NSMutableDictionary new];
        _overlayComponentModelBuilders = [NSMutableDictionary new];
        _bodyComponentIdentifierOrder = [NSMutableArray new];
        _overlayComponentIdentifierOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - HUBViewModelBuilder

- (nullable NSError *)addJSONData:(NSData *)JSONData
{
    NSError *error;
    NSObject *JSONObject = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];
    
    if (error != nil || JSONObject == nil) {
        return error;
    }
    
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        [self addDataFromJSONDictionary:(NSDictionary *)JSONObject];
    } else if ([JSONObject isKindOfClass:[NSArray class]]) {
        [self addDataFromJSONArray:(NSArray *)JSONObject];
    } else {
        return [NSError errorWithDomain:@"spotify.com.hubFramework.invalidJSON" code:0 userInfo:nil];
    }
    
    return nil;
}

- (id<HUBComponentModelBuilder>)headerComponentModelBuilder
{
    return [self getOrCreateBuilderForHeaderComponentModelWithIdentifier:nil];
}

- (BOOL)headerComponentModelBuilderExists
{
    return self.headerComponentModelBuilderImplementation != nil;
}

- (BOOL)builderExistsForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return self.bodyComponentModelBuilders[identifier] != nil;
}

- (BOOL)builderExistsForOverlayComponentModelWithIdentifier:(NSString *)identifier
{
    return self.overlayComponentModelBuilders[identifier] != nil;
}

- (NSArray<id<HUBComponentModelBuilder>> *)allBodyComponentModelBuilders
{
    NSMutableArray<id<HUBComponentModelBuilder>> * const builders = [NSMutableArray new];
    
    [self enumerateBodyComponentModelBuildersWithBlock:^BOOL(id<HUBComponentModelBuilder> builder) {
        [builders addObject:builder];
        return YES;
    }];
    
    return [builders copy];
}

- (id<HUBComponentModelBuilder>)builderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForBodyComponentModelWithIdentifier:identifier];
}

- (id<HUBComponentModelBuilder>)builderForOverlayComponentModelWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForOverlayComponentModelWithIdentifier:identifier];
}

- (void)enumerateAllComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    NSParameterAssert(block != nil);
    
    if (self.headerComponentModelBuilderImplementation != nil) {
        id<HUBComponentModelBuilder> const headerComponentModelBuilder = self.headerComponentModelBuilderImplementation;
        
        if (!block(headerComponentModelBuilder)) {
            return;
        }
    }
    
    if (![self enumerateBodyComponentModelBuildersWithBlock:block]) {
        return;
    }
    
    [self enumerateOverlayComponentModelBuildersWithBlock:block];
}

- (void)removeHeaderComponentModelBuilder
{
    if (self.headerComponentModelBuilderImplementation == nil) {
        return;
    }
    
    self.headerComponentModelBuilderImplementation = nil;
    [self.modificationDelegate modifiableWasModified:self];
}

- (void)removeBuilderForBodyComponentModelWithIdentifier:(NSString *)identifier
{
    if (self.bodyComponentModelBuilders[identifier] == nil) {
        return;
    }
    
    [self.bodyComponentModelBuilders removeObjectForKey:identifier];
    [self.bodyComponentIdentifierOrder removeObject:identifier];
    [self.modificationDelegate modifiableWasModified:self];
}

- (void)removeBuilderForOverlayComponentModelWithIdentifier:(NSString *)identifier
{
    if (self.overlayComponentModelBuilders[identifier] == nil) {
        return;
    }
    
    [self.overlayComponentModelBuilders removeObjectForKey:identifier];
    [self.overlayComponentIdentifierOrder removeObject:identifier];
    [self.modificationDelegate modifiableWasModified:self];
}

- (void)removeAllComponentModelBuilders
{
    [self removeHeaderComponentModelBuilder];
    
    [self.bodyComponentModelBuilders removeAllObjects];
    [self.bodyComponentIdentifierOrder removeAllObjects];
    
    [self.overlayComponentModelBuilders removeAllObjects];
    [self.overlayComponentIdentifierOrder removeAllObjects];
    
    [self.modificationDelegate modifiableWasModified:self];
}

#pragma mark - API

- (BOOL)isEmpty
{
    if (self.headerComponentModelBuilderImplementation != nil) {
        return NO;
    }
    
    if (self.bodyComponentModelBuilders.count > 0) {
        return NO;
    }
    
    if (self.overlayComponentModelBuilders.count > 0) {
        return NO;
    }
    
    return YES;
}

- (HUBViewModelImplementation *)build
{
    HUBComponentModelImplementation * const headerComponentModel = [self.headerComponentModelBuilderImplementation buildForIndex:0];
    
    NSArray * const bodyComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.bodyComponentModelBuilders
                                                                                                    identifierOrder:self.bodyComponentIdentifierOrder];
    
    NSArray * const overlayComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.overlayComponentModelBuilders
                                                                                                       identifierOrder:self.overlayComponentIdentifierOrder];
    
    return [[HUBViewModelImplementation alloc] initWithIdentifier:self.viewIdentifier
                                                featureIdentifier:self.featureIdentifier
                                               navigationBarTitle:self.navigationBarTitle
                                             headerComponentModel:headerComponentModel
                                              bodyComponentModels:bodyComponentModels
                                           overlayComponentModels:overlayComponentModels
                                                     extensionURL:self.extensionURL
                                                       customData:[self.customData copy]];
}

#pragma mark - HUBJSONCompatibleBuilder

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBViewModelJSONSchema> const viewModelSchema = self.JSONSchema.viewModelSchema;
    
    NSString * const viewIdentifier = [viewModelSchema.identifierPath stringFromJSONDictionary:dictionary];
    
    if (viewIdentifier != nil) {
        self.viewIdentifier = viewIdentifier;
    }
    
    NSString * const featureIdentifier = [viewModelSchema.featureIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (featureIdentifier != nil) {
        self.featureIdentifier = featureIdentifier;
    }
    
    NSString * const navigationBarTitle = [viewModelSchema.navigationBarTitlePath stringFromJSONDictionary:dictionary];
    
    if (navigationBarTitle != nil) {
        self.navigationBarTitle = navigationBarTitle;
    }
    
    NSURL * const extensionURL = [viewModelSchema.extensionURLPath URLFromJSONDictionary:dictionary];
    
    if (extensionURL != nil) {
        self.extensionURL = extensionURL;
    }
    
    NSDictionary * const customData = [viewModelSchema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (customData != nil) {
        NSDictionary * const existingCustomData = self.customData;
        
        if (existingCustomData != nil) {
            NSMutableDictionary * const mutableCustomData = [existingCustomData mutableCopy];
            [mutableCustomData addEntriesFromDictionary:customData];
            self.customData = [mutableCustomData copy];
        } else {
            self.customData = customData;
        }
    }
    
    NSDictionary * const headerComponentModelDictionary = [viewModelSchema.headerComponentModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (headerComponentModelDictionary != nil) {
        NSString * const headerComponentModelIdentifier = [self.JSONSchema.componentModelSchema.identifierPath stringFromJSONDictionary:headerComponentModelDictionary];
        HUBComponentModelBuilderImplementation * const headerComponentModelBuilder = [self getOrCreateBuilderForHeaderComponentModelWithIdentifier:headerComponentModelIdentifier];
        [headerComponentModelBuilder addDataFromJSONDictionary:headerComponentModelDictionary];
    }
    
    NSArray * const bodyComponentModelDictionaries = [viewModelSchema.bodyComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const componentModelDictionary in bodyComponentModelDictionaries) {
        [self addDataFromBodyComponentModelJSONDictionary:componentModelDictionary];
    }
    
    NSArray * const overlayComponentModelDictionaries = [viewModelSchema.overlayComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const componentModelDictionary in overlayComponentModelDictionaries) {
        NSString * const componentIdentifier = [self.JSONSchema.componentModelSchema.identifierPath stringFromJSONDictionary:componentModelDictionary];
        HUBComponentModelBuilderImplementation * const componentModelBuilder = [self getOrCreateBuilderForOverlayComponentModelWithIdentifier:componentIdentifier];
        [componentModelBuilder addDataFromJSONDictionary:componentModelDictionary];
    }
}

#pragma mark - HUBModificationDelegate

- (void)modifiableWasModified:(id<HUBModifiable>)modifiable
{
    [self.modificationDelegate modifiableWasModified:self];
}

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBViewModelBuilder with contents: %@", HUBSerializeToString([self build])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBViewModelBuilderImplementation * const copy = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                                                               JSONSchema:self.JSONSchema
                                                                                                        componentDefaults:self.componentDefaults
                                                                                                        iconImageResolver:self.iconImageResolver];
    
    copy.viewIdentifier = self.viewIdentifier;
    copy.navigationBarTitle = self.navigationBarTitle;
    copy.extensionURL = self.extensionURL;
    copy.customData = self.customData;
    copy.headerComponentModelBuilderImplementation = [self.headerComponentModelBuilderImplementation copy];
    copy.headerComponentModelBuilderImplementation.modificationDelegate = self;
    
    for (NSString * const builderIdentifier in self.bodyComponentModelBuilders) {
        HUBComponentModelBuilderImplementation * const builderCopy = [self.bodyComponentModelBuilders[builderIdentifier] copy];
        builderCopy.modificationDelegate = copy;
        copy.bodyComponentModelBuilders[builderIdentifier] = builderCopy;
    }
    
    for (NSString * const builderIdentifier in self.overlayComponentModelBuilders) {
        HUBComponentModelBuilderImplementation * const builderCopy = [self.overlayComponentModelBuilders[builderIdentifier] copy];
        builderCopy.modificationDelegate = copy;
        copy.overlayComponentModelBuilders[builderIdentifier] = builderCopy;
    }
    
    [copy.bodyComponentIdentifierOrder addObjectsFromArray:self.bodyComponentIdentifierOrder];
    [copy.overlayComponentIdentifierOrder addObjectsFromArray:self.overlayComponentIdentifierOrder];
    
    return copy;
}

#pragma mark - Private utilities

- (void)addDataFromJSONArray:(NSArray<NSObject *> *)array
{
    for (NSObject * const object in array) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [self addDataFromBodyComponentModelJSONDictionary:(NSDictionary *)object];
        }
    }
}

- (void)addDataFromBodyComponentModelJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    NSString * const identifier = [self.JSONSchema.componentModelSchema.identifierPath stringFromJSONDictionary:dictionary];
    HUBComponentModelBuilderImplementation * const builder = [self getOrCreateBuilderForBodyComponentModelWithIdentifier:identifier];
    [builder addDataFromJSONDictionary:dictionary];
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForHeaderComponentModelWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = self.headerComponentModelBuilderImplementation;
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    if (identifier == nil) {
        identifier = @"header";
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [self createComponentModelBuilderWithIdentifier:identifier];
    self.headerComponentModelBuilderImplementation = newBuilder;
    return newBuilder;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForBodyComponentModelWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = [self existingComponentModelBuilderFromDictionary:self.bodyComponentModelBuilders
                                                                                                       modelIdentifier:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [self createComponentModelBuilderWithIdentifier:identifier];
    self.bodyComponentModelBuilders[newBuilder.modelIdentifier] = newBuilder;
    [self.bodyComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForOverlayComponentModelWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const existingBuilder = [self existingComponentModelBuilderFromDictionary:self.overlayComponentModelBuilders
                                                                                                       modelIdentifier:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [self createComponentModelBuilderWithIdentifier:identifier];
    self.overlayComponentModelBuilders[newBuilder.modelIdentifier] = newBuilder;
    [self.overlayComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (nullable HUBComponentModelBuilderImplementation *)existingComponentModelBuilderFromDictionary:(NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *)dictionary
                                                                                 modelIdentifier:(nullable NSString *)modelIdentifier
{
    if (modelIdentifier == nil) {
        return nil;
    }
    
    NSString * const existingBuilderIdentifier = modelIdentifier;
    HUBComponentModelBuilderImplementation * const existingBuilder = dictionary[existingBuilderIdentifier];
    return existingBuilder;
}


- (HUBComponentModelBuilderImplementation *)createComponentModelBuilderWithIdentifier:(nullable NSString *)identifier
{
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                                                                   featureIdentifier:self.featureIdentifier
                                                                                                                          JSONSchema:self.JSONSchema
                                                                                                                   componentDefaults:self.componentDefaults
                                                                                                                   iconImageResolver:self.iconImageResolver
                                                                                                                mainImageDataBuilder:nil
                                                                                                          backgroundImageDataBuilder:nil];
    
    builder.modificationDelegate = self;
    return builder;
}

- (BOOL)enumerateBodyComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    return [self enumerateComponentModelBuilders:self.bodyComponentModelBuilders
                                 identifierOrder:self.bodyComponentIdentifierOrder
                                       withBlock:block];
}

- (BOOL)enumerateOverlayComponentModelBuildersWithBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    return [self enumerateComponentModelBuilders:self.overlayComponentModelBuilders
                                 identifierOrder:self.overlayComponentIdentifierOrder
                                       withBlock:block];
}

- (BOOL)enumerateComponentModelBuilders:(NSDictionary<NSString *, id<HUBComponentModelBuilder>> *)builders
                        identifierOrder:(NSArray<NSString *> *)identifierOrder
                              withBlock:(BOOL(^)(id<HUBComponentModelBuilder>))block
{
    for (NSString * const identifier in identifierOrder) {
        id<HUBComponentModelBuilder> const builder = builders[identifier];
        
        if (!block(builder)) {
            return NO;
        }
    }
    
    return YES;
}

@end

NS_ASSUME_NONNULL_END
