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
@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
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
    NSMutableOrderedSet<HUBComponentModelBuilderImplementation *> * const sortedBuilders = [NSMutableOrderedSet new];
    NSMutableDictionary<NSNumber *, HUBComponentModelBuilderImplementation *> * const buildersByPreferredIndex = [NSMutableDictionary new];
    
    for (NSString * const identifier in identifierOrder) {
        HUBComponentModelBuilderImplementation * const builder = builders[identifier];
        
        if (builder == nil) {
            continue;
        }
        
        NSNumber * const preferredIndex = builder.preferredIndex;
        
        if (preferredIndex != nil) {
            buildersByPreferredIndex[preferredIndex] = builder;
        }
        
        [sortedBuilders addObject:builder];
    }
    
    for (NSNumber * const preferredIndex in buildersByPreferredIndex.allKeys) {
        HUBComponentModelBuilderImplementation * const builder = buildersByPreferredIndex[preferredIndex];
        NSUInteger decodedPreferredIndex = preferredIndex.unsignedIntegerValue;
        
        [sortedBuilders removeObject:builder];
        
        if (decodedPreferredIndex >= sortedBuilders.count) {
            [sortedBuilders addObject:builder];
        } else {
            [sortedBuilders insertObject:builder atIndex:decodedPreferredIndex];
        }
    }
    
    NSMutableArray<id<HUBComponentModel>> * const models = [NSMutableArray new];
    NSUInteger modelIndex = 0;
    
    for (HUBComponentModelBuilderImplementation * const builder in sortedBuilders) {
        id<HUBComponentModel> const model = [builder buildForIndex:modelIndex];
        
        if (model != nil) {
            [models addObject:model];
            modelIndex++;
        }
    }
    
    return models;
}

#pragma mark - Initializer

- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                      featureIdentifier:(NSString *)featureIdentifier
                             JSONSchema:(id<HUBJSONSchema>)JSONSchema
              defaultComponentNamespace:(NSString *)defaultComponentNamespace
{
    NSParameterAssert(featureIdentifier != nil);
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(defaultComponentNamespace != nil);
    
    if (modelIdentifier == nil) {
        modelIdentifier = [NSString stringWithFormat:@"UnknownComponent:%@", [NSUUID UUID].UUIDString];
    }
    
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _modelIdentifier = (NSString *)modelIdentifier;
        _componentNamespace = [defaultComponentNamespace copy];
        _defaultComponentNamespace = [defaultComponentNamespace copy];
        _featureIdentifier = [featureIdentifier copy];
        _mainImageDataBuilderImplementation = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema];
        _backgroundImageDataBuilderImplementation = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema];
        _customImageDataBuilders = [NSMutableDictionary new];
        _childComponentModelBuilders = [NSMutableDictionary new];
        _childComponentIdentifierOrder = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - HUBComponentModelBuilder

- (id<HUBComponentImageDataBuilder>)mainImageDataBuilder
{
    return self.mainImageDataBuilderImplementation;
}

- (nullable NSURL *)mainImageURL
{
    return self.mainImageDataBuilder.URL;
}

- (void)setMainImageURL:(nullable NSURL *)mainImageURL
{
    self.mainImageDataBuilder.URL = mainImageURL;
}

- (nullable UIImage *)mainImage
{
    return self.mainImageDataBuilder.localImage;
}

- (void)setMainImage:(nullable UIImage *)mainImage
{
    self.mainImageDataBuilder.localImage = mainImage;
}

- (id<HUBComponentImageDataBuilder>)backgroundImageDataBuilder
{
    return self.backgroundImageDataBuilderImplementation;
}

- (id<HUBViewModelBuilder>)targetInitialViewModelBuilder
{
    return [self getOrCreateBuilderForTargetInitialViewModel];
}

- (nullable NSURL *)backgroundImageURL
{
    return self.backgroundImageDataBuilder.URL;
}

- (void)setBackgroundImageURL:(nullable NSURL *)backgroundImageURL
{
    self.backgroundImageDataBuilder.URL = backgroundImageURL;
}

- (nullable UIImage *)backgroundImage
{
    return self.backgroundImageDataBuilder.localImage;
}

- (void)setBackgroundImage:(nullable UIImage *)backgroundImage
{
    self.backgroundImageDataBuilder.localImage = backgroundImage;
}

- (BOOL)builderExistsForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return self.customImageDataBuilders[identifier] != nil;
}

- (id<HUBComponentImageDataBuilder>)builderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return [self getOrCreateBuilderForCustomImageDataWithIdentifier:identifier];
}

- (BOOL)builderExistsForChildComponentModelWithIdentifier:(NSString *)identifier
{
    return self.childComponentModelBuilders[identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForChildComponentModelWithIdentifier:(NSString *)modelIdentifier
{
    return [self getOrCreateBuilderForChildComponentModelWithIdentifier:modelIdentifier];
}

- (void)removeAllChildComponentModelBuilders
{
    [self.childComponentModelBuilders removeAllObjects];
    [self.childComponentIdentifierOrder removeAllObjects];
}

#pragma mark - HUBJSONCompatibleBuilder

- (void)addDataFromJSONDictionary:(NSDictionary<NSString *, NSObject *> *)dictionary
{
    id<HUBComponentModelJSONSchema> componentModelSchema = self.JSONSchema.componentModelSchema;
    
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
    
    NSString * const contentIdentifier = [componentModelSchema.contentIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (contentIdentifier != nil) {
        self.contentIdentifier = contentIdentifier;
    }
    
    NSString * const title = [componentModelSchema.titlePath stringFromJSONDictionary:dictionary];
    
    if (title != nil) {
        self.title = title;
    }
    
    NSString * const subtitle = [componentModelSchema.subtitlePath stringFromJSONDictionary:dictionary];
    
    if (subtitle != nil) {
        self.subtitle = subtitle;
    }
    
    NSString * const accessoryTitle = [componentModelSchema.accessoryTitlePath stringFromJSONDictionary:dictionary];
    
    if (accessoryTitle != nil) {
        self.accessoryTitle = accessoryTitle;
    }
    
    NSString * const descriptionText = [componentModelSchema.descriptionTextPath stringFromJSONDictionary:dictionary];
    
    if (descriptionText != nil) {
        self.descriptionText = descriptionText;
    }
    
    NSURL * const targetURL = [componentModelSchema.targetURLPath URLFromJSONDictionary:dictionary];
    
    if (targetURL != nil) {
        self.targetURL = targetURL;
    }
    
    NSDictionary * const targetInitialViewModelDictionary = [componentModelSchema.targetInitialViewModelDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (targetInitialViewModelDictionary != nil) {
        [[self getOrCreateBuilderForTargetInitialViewModel] addDataFromJSONDictionary:targetInitialViewModelDictionary];
    }
    
    NSDictionary * const loggingData = [componentModelSchema.loggingDataPath dictionaryFromJSONDictionary:dictionary];
    
    if (loggingData != nil) {
        NSDictionary * const existingLoggingData = self.loggingData;
        
        if (existingLoggingData != nil) {
            NSMutableDictionary * const mutableLoggingData = [existingLoggingData mutableCopy];
            [mutableLoggingData addEntriesFromDictionary:loggingData];
            self.loggingData = [mutableLoggingData copy];
        } else {
            self.loggingData = loggingData;
        }
    }
    
    NSDate * const date = [componentModelSchema.datePath dateFromJSONDictionary:dictionary];
    
    if (date != nil) {
        self.date = date;
    }
    
    NSDictionary * const customData = [componentModelSchema.customDataPath dictionaryFromJSONDictionary:dictionary];
    
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
    
    NSDictionary * const mainImageDataDictionary = [componentModelSchema.mainImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (mainImageDataDictionary != nil) {
        [self.mainImageDataBuilderImplementation addDataFromJSONDictionary:mainImageDataDictionary];
    }
    
    NSDictionary * const backgroundImageDataDictionary = [componentModelSchema.backgroundImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    if (backgroundImageDataDictionary != nil) {
        [self.backgroundImageDataBuilderImplementation addDataFromJSONDictionary:backgroundImageDataDictionary];
    }
    
    NSDictionary * const customImageDataDictionary = [componentModelSchema.customImageDataDictionaryPath dictionaryFromJSONDictionary:dictionary];
    
    for (NSString * const imageIdentifier in customImageDataDictionary.allKeys) {
        NSDictionary * const imageDataDictionary = customImageDataDictionary[imageIdentifier];
        
        if ([imageDataDictionary isKindOfClass:[NSDictionary class]]) {
            HUBComponentImageDataBuilderImplementation * const builder = [self getOrCreateBuilderForCustomImageDataWithIdentifier:imageIdentifier];
            [builder addDataFromJSONDictionary:imageDataDictionary];
        }
    }
    
    NSArray * const childComponentModelDictionaries = [componentModelSchema.childComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const childComponentModelDictionary in childComponentModelDictionaries) {
        NSString * const childModelIdentifier = [componentModelSchema.identifierPath stringFromJSONDictionary:childComponentModelDictionary];
        HUBComponentModelBuilderImplementation * const childModelBuilder = [self getOrCreateBuilderForChildComponentModelWithIdentifier:childModelIdentifier];
        [childModelBuilder addDataFromJSONDictionary:childComponentModelDictionary];
    }
}

#pragma mark - API

- (nullable HUBComponentModelImplementation *)buildForIndex:(NSUInteger)index
{
    NSString * const componentName = self.componentName;
    
    if (componentName == nil) {
        return nil;
    }
    
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:self.componentNamespace
                                                                                                      name:componentName];
    
    id<HUBComponentImageData> const mainImageData = [self.mainImageDataBuilderImplementation buildWithIdentifier:nil
                                                                                                            type:HUBComponentImageTypeMain];
    
    id<HUBComponentImageData> const backgroundImageData = [self.backgroundImageDataBuilderImplementation buildWithIdentifier:nil
                                                                                                                        type:HUBComponentImageTypeBackground];
    
    NSMutableDictionary * const customImageData = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageDataBuilders.allKeys) {
        HUBComponentImageDataBuilderImplementation * const builder = self.customImageDataBuilders[imageIdentifier];
        id<HUBComponentImageData> const imageData = [builder buildWithIdentifier:imageIdentifier type:HUBComponentImageTypeCustom];
        
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
                                                                 index:index
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
    HUBComponentImageDataBuilderImplementation * const existingBuilder = self.customImageDataBuilders[identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentImageDataBuilderImplementation * const newBuilder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema];
    [self.customImageDataBuilders setObject:newBuilder forKey:identifier];
    return newBuilder;
}

- (HUBViewModelBuilderImplementation *)getOrCreateBuilderForTargetInitialViewModel
{
    // Lazily computed to avoid infinite recursion
    if (self.targetInitialViewModelBuilderImplementation == nil) {
        self.targetInitialViewModelBuilderImplementation = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier
                                                                                                                     JSONSchema:self.JSONSchema
                                                                                                      defaultComponentNamespace:self.defaultComponentNamespace];
    }
    
    return (HUBViewModelBuilderImplementation *)self.targetInitialViewModelBuilderImplementation;
}

- (HUBComponentModelBuilderImplementation *)getOrCreateBuilderForChildComponentModelWithIdentifier:(nullable NSString *)identifier
{
    if (identifier != nil) {
        NSString * const existingBuilderIdentifier = identifier;
        HUBComponentModelBuilderImplementation * const existingBuilder = self.childComponentModelBuilders[existingBuilderIdentifier];
        
        if (existingBuilder != nil) {
            return existingBuilder;
        }
    }
    
    HUBComponentModelBuilderImplementation * const newBuilder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:identifier
                                                                                                                      featureIdentifier:self.featureIdentifier
                                                                                                                             JSONSchema:self.JSONSchema
                                                                                                              defaultComponentNamespace:self.defaultComponentNamespace];
    
    [self.childComponentModelBuilders setObject:newBuilder forKey:newBuilder.modelIdentifier];
    [self.childComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

@end

NS_ASSUME_NONNULL_END
