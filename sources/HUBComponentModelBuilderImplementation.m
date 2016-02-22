#import "HUBComponentModelBuilderImplementation.h"

#import "HUBComponentIdentifier.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBJSONSchema.h"
#import "HUBComponentModelJSONSchema.h"
#import "HUBJSONPath.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderImplementation ()

@property (nonatomic, copy, readonly) NSString *featureIdentifier;
@property (nonatomic, copy, readonly) NSString *defaultComponentNamespace;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *mainImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *backgroundImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentImageDataBuilderImplementation *> *customImageDataBuilders;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *targetInitialViewModelBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *childComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *childComponentIdentifierOrder;

@end

@implementation HUBComponentModelBuilderImplementation

@synthesize modelIdentifier = _modelIdentifier;
@synthesize componentNamespace = _componentNamespace;
@synthesize componentName = _componentName;
@synthesize contentIdentifier = _contentIdentifier;
@synthesize preferredIndex = _preferredIndex;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize accessoryTitle = _accessoryTitle;
@synthesize descriptionText = _descriptionText;
@synthesize targetURL = _targetURL;
@synthesize customData = _customData;
@synthesize loggingData = _loggingData;
@synthesize date = _date;

#pragma mark - Class methods

+ (NSArray<HUBComponentModelImplementation *> *)buildComponentModelsUsingBuilders:(NSDictionary<NSString *,HUBComponentModelBuilderImplementation *> *)builders
                                                                  identifierOrder:(NSArray<NSString *> *)identifierOrder
{
    NSMutableArray * const models = [NSMutableArray new];
    NSMutableDictionary * const modelsByPreferredIndex = [NSMutableDictionary new];
    
    for (NSString * const identifier in identifierOrder) {
        HUBComponentModelBuilderImplementation * const builder = builders[identifier];
        
        if (builder == nil) {
            continue;
        }
        
        HUBComponentModelImplementation * const model = [builder build];
        
        if (model == nil) {
            continue;
        }
        
        [models addObject:model];
        
        NSNumber * const preferredIndex = builder.preferredIndex;
        
        if (preferredIndex != nil) {
            modelsByPreferredIndex[preferredIndex] = model;
        }
    }
    
    for (NSNumber * const preferredIndex in modelsByPreferredIndex.allKeys) {
        NSUInteger decodedPreferredIndex = preferredIndex.unsignedIntegerValue;
        
        if (decodedPreferredIndex >= models.count) {
            continue;
        }
        
        HUBComponentModelImplementation * const model = modelsByPreferredIndex[preferredIndex];
        [models removeObject:model];
        [models insertObject:model atIndex:decodedPreferredIndex];
    }
    
    return models;
}

#pragma mark - Initializer

- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                      featureIdentifier:(NSString *)featureIdentifier
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(defaultComponentNamespace != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    if (modelIdentifier == nil) {
        modelIdentifier = [NSString stringWithFormat:@"UnknownComponent:%@", [NSUUID UUID].UUIDString];
    }
    
    _modelIdentifier = (NSString *)modelIdentifier;
    _componentNamespace = [defaultComponentNamespace copy];
    _defaultComponentNamespace = [defaultComponentNamespace copy];
    _featureIdentifier = [featureIdentifier copy];
    _mainImageDataBuilderImplementation = [HUBComponentImageDataBuilderImplementation new];
    _backgroundImageDataBuilderImplementation = [HUBComponentImageDataBuilderImplementation new];
    _customImageDataBuilders = [NSMutableDictionary new];
    _childComponentModelBuilders = [NSMutableDictionary new];
    _childComponentIdentifierOrder = [NSMutableArray new];
    
    return self;
}

#pragma mark - HUBComponentModelBuilder

- (id<HUBComponentImageDataBuilder>)mainImageDataBuilder
{
    return self.mainImageDataBuilderImplementation;
}

- (id<HUBComponentImageDataBuilder>)backgroundImageDataBuilder
{
    return self.backgroundImageDataBuilderImplementation;
}

- (id<HUBViewModelBuilder>)targetInitialViewModelBuilder
{
    return [self getOrCreateBuilderForTargetInitialViewModel];
}

- (BOOL)builderExistsForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return [self.customImageDataBuilders objectForKey:identifier] != nil;
}

- (id<HUBComponentImageDataBuilder>)builderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForCustomImageDataWithIdentifier:identifier];
}

- (BOOL)builderExistsForChildComponentModelWithIdentifier:(NSString *)identifier
{
    return [self.childComponentModelBuilders objectForKey:identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForChildComponentModelWithIdentifier:(NSString *)modelIdentifier
{
    return [self getOrCreateBuilderForChildComponentModelWithIdentifier:modelIdentifier];
}

#pragma mark - HUBJSONCompatibleBuilder

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary usingSchema:(id<HUBJSONSchema>)schema
{
    id<HUBComponentModelJSONSchema> componentModelSchema = schema.componentModelSchema;
    
    self.contentIdentifier = [componentModelSchema.contentIdentifierPath stringFromJSONDictionary:dictionary];
    self.title = [componentModelSchema.titlePath stringFromJSONDictionary:dictionary];
    self.subtitle = [componentModelSchema.subtitlePath stringFromJSONDictionary:dictionary];
    self.accessoryTitle = [componentModelSchema.accessoryTitlePath stringFromJSONDictionary:dictionary];
    self.descriptionText = [componentModelSchema.descriptionTextPath stringFromJSONDictionary:dictionary];
    self.targetURL = [componentModelSchema.targetURLPath URLFromJSONDictionary:dictionary];
    self.customData = [componentModelSchema.customDataPath dictionaryFromJSONDictionary:dictionary];
    self.loggingData = [componentModelSchema.loggingDataPath dictionaryFromJSONDictionary:dictionary];
    self.date = [componentModelSchema.datePath dateFromJSONDictionary:dictionary];
    
    NSString * const componentIdentifierString = [componentModelSchema.componentIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (componentIdentifierString != nil) {
        NSArray * const componentIdentifierParts = [componentIdentifierString componentsSeparatedByString:@":"];
        
        if (componentIdentifierParts.count > 1) {
            self.componentNamespace = componentIdentifierParts[0];
            self.componentName = componentIdentifierParts[1];
        } else if (componentIdentifierParts.count == 1) {
            self.componentName = componentIdentifierParts[0];
        }
    }
    
    NSDictionary * const mainImageDataDictionary = [componentModelSchema.mainImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (mainImageDataDictionary != nil) {
        [self.mainImageDataBuilderImplementation addDataFromJSONDictionary:mainImageDataDictionary usingSchema:schema];
    }
    
    NSDictionary * const backgroundImageDataDictionary = [componentModelSchema.backgroundImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (backgroundImageDataDictionary != nil) {
        [self.backgroundImageDataBuilderImplementation addDataFromJSONDictionary:backgroundImageDataDictionary usingSchema:schema];
    }
    
    NSDictionary * const customImageDataDictionary = [componentModelSchema.customImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    for (NSString * const imageIdentifier in customImageDataDictionary.allKeys) {
        NSDictionary * const imageDataDictionary = [customImageDataDictionary objectForKey:imageIdentifier];
        
        if ([imageDataDictionary isKindOfClass:[NSDictionary class]]) {
            HUBComponentImageDataBuilderImplementation * const builder = [self getOrCreateBuilderForCustomImageDataWithIdentifier:imageIdentifier];
            [builder addDataFromJSONDictionary:imageDataDictionary usingSchema:schema];
        }
    }
    
    NSDictionary * const targetInitialViewModelDictionary = [componentModelSchema.targetInitialViewModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (targetInitialViewModelDictionary != nil) {
        [[self getOrCreateBuilderForTargetInitialViewModel] addDataFromJSONDictionary:targetInitialViewModelDictionary usingSchema:schema];
    }
    
    NSArray * const childComponentModelDictionaries = [componentModelSchema.childComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const childComponentModelDictionary in childComponentModelDictionaries) {
        NSString * const childModelIdentifier = [componentModelSchema.identifierPath stringFromJSONDictionary:childComponentModelDictionary];
        HUBComponentModelBuilderImplementation * const childModelBuilder = [self getOrCreateBuilderForChildComponentModelWithIdentifier:childModelIdentifier];
        [childModelBuilder addDataFromJSONDictionary:childComponentModelDictionary usingSchema:schema];
    }
}

#pragma mark - API

- (nullable HUBComponentModelImplementation *)build
{
    NSString * const componentName = self.componentName;
    
    if (componentName == nil) {
        return nil;
    }
    
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:self.componentNamespace
                                                                                                      name:componentName];
    
    id<HUBComponentImageData> const mainImageData = [self.mainImageDataBuilderImplementation buildWithIdentifier:nil];
    id<HUBComponentImageData> const backgroundImageData = [self.backgroundImageDataBuilderImplementation buildWithIdentifier:nil];
    
    NSMutableDictionary * const customImageData = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageDataBuilders.allKeys) {
        HUBComponentImageDataBuilderImplementation * const builder = self.customImageDataBuilders[imageIdentifier];
        id<HUBComponentImageData> const imageData = [builder buildWithIdentifier:imageIdentifier];
        
        if (imageData != nil) {
            [customImageData setObject:imageData forKey:imageIdentifier];
        }
    }
    
    id<HUBViewModel> const targetInitialViewModel = [self.targetInitialViewModelBuilderImplementation build];
    
    NSArray * const childComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.childComponentModelBuilders
                                                                                                     identifierOrder:self.childComponentIdentifierOrder];
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:self.modelIdentifier
                                                   componentIdentifier:componentIdentifier
                                                     contentIdentifier:self.contentIdentifier
                                                                 title:self.title
                                                              subtitle:self.subtitle
                                                        accessoryTitle:self.accessoryTitle
                                                       descriptionText:self.descriptionText
                                                         mainImageData:mainImageData
                                                   backgroundImageData:backgroundImageData
                                                       customImageData:customImageData
                                                             targetURL:self.targetURL
                                                targetInitialViewModel:targetInitialViewModel
                                                            customData:self.customData
                                                           loggingData:self.loggingData
                                                                  date:self.date
                                                  childComponentModels:childComponentModels];
}

#pragma mark - Private utilities

- (HUBComponentImageDataBuilderImplementation *)getOrCreateBuilderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    HUBComponentImageDataBuilderImplementation * const existingBuilder = [self.customImageDataBuilders objectForKey:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentImageDataBuilderImplementation * const newBuilder = [HUBComponentImageDataBuilderImplementation new];
    [self.customImageDataBuilders setObject:newBuilder forKey:identifier];
    return newBuilder;
}

- (HUBViewModelBuilderImplementation *)getOrCreateBuilderForTargetInitialViewModel
{
    // Lazily computed to avoid infinite recursion
    if (self.targetInitialViewModelBuilderImplementation == nil) {
        self.targetInitialViewModelBuilderImplementation = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                                                      defaultComponentNamespace:self.defaultComponentNamespace];
    }
    
    return (HUBViewModelBuilderImplementation *)self.targetInitialViewModelBuilderImplementation;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForChildComponentModelWithIdentifier:(nullable NSString *)identifier
{
    if (identifier != nil) {
        NSString * const existingBuilderIdentifier = identifier;
        HUBComponentModelBuilderImplementation * const existingBuilder = [self.childComponentModelBuilders objectForKey:existingBuilderIdentifier];
        
        if (existingBuilder != nil) {
            return existingBuilder;
        }
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                                                                      featureIdentifier:self.featureIdentifier
                                                                                                              defaultComponentNamespace:self.defaultComponentNamespace];
    
    [self.childComponentModelBuilders setObject:newBuilder forKey:newBuilder.modelIdentifier];
    [self.childComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

@end

NS_ASSUME_NONNULL_END
