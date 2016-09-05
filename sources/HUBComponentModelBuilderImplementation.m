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
#import "HUBComponentDefaults.h"
#import "HUBIconImplementation.h"
#import "HUBUtilities.h"
#import "HUBImplementationMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderImplementation ()

@property (nonatomic, strong, readonly) id<HUBJSONSchema> JSONSchema;
@property (nonatomic, strong, readonly) HUBComponentDefaults *componentDefaults;
@property (nonatomic, strong, nullable, readonly) id<HUBIconImageResolver> iconImageResolver;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *mainImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *backgroundImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentImageDataBuilderImplementation *> *customImageDataBuilders;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *targetInitialViewModelBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentModelBuilderImplementation *> *childComponentModelBuilders;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *childComponentIdentifierOrder;

@end

@implementation HUBComponentModelBuilderImplementation

#pragma mark - Property synthesization

@synthesize modelIdentifier = _modelIdentifier;
@synthesize preferredIndex = _preferredIndex;
@synthesize componentNamespace = _componentNamespace;
@synthesize componentName = _componentName;
@synthesize componentCategory = _componentCategory;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize accessoryTitle = _accessoryTitle;
@synthesize descriptionText = _descriptionText;
@synthesize iconIdentifier = _iconIdentifier;
@synthesize targetURL = _targetURL;
@synthesize metadata = _metadata;
@synthesize loggingData = _loggingData;
@synthesize customData = _customData;

#pragma mark - Class methods

+ (NSArray<id<HUBComponentModel>> *)buildComponentModelsUsingBuilders:(NSDictionary<NSString *,HUBComponentModelBuilderImplementation *> *)builders
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
    
    for (NSNumber * const preferredIndex in buildersByPreferredIndex) {
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
    
    for (HUBComponentModelBuilderImplementation * const builder in sortedBuilders) {
        id<HUBComponentModel> const model = [builder buildForIndex:models.count];
        [models addObject:model];
    }
    
    return [models copy];
}

#pragma mark - Initializer

- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                             JSONSchema:(id<HUBJSONSchema>)JSONSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                   mainImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)mainImageDataBuilder
             backgroundImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)backgroundImageDataBuilder
{
    NSParameterAssert(JSONSchema != nil);
    NSParameterAssert(componentDefaults != nil);
    
    if (modelIdentifier == nil) {
        modelIdentifier = [NSString stringWithFormat:@"UnknownComponent:%@", [NSUUID UUID].UUIDString];
    }
    
    self = [super init];
    
    if (self) {
        _JSONSchema = JSONSchema;
        _componentDefaults = componentDefaults;
        _iconImageResolver = iconImageResolver;
        
        _modelIdentifier = (NSString *)modelIdentifier;
        _componentNamespace = [componentDefaults.componentNamespace copy];
        _componentName = [componentDefaults.componentName copy];
        _componentCategory = [componentDefaults.componentCategory copy];
        
        if (mainImageDataBuilder != nil) {
            HUBComponentImageDataBuilderImplementation * const nonNilMainImageDataBuilder = mainImageDataBuilder;
            _mainImageDataBuilderImplementation = nonNilMainImageDataBuilder;
        } else {
            _mainImageDataBuilderImplementation = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                                                       iconImageResolver:iconImageResolver];
        }
        
        if (backgroundImageDataBuilder != nil) {
            HUBComponentImageDataBuilderImplementation * const nonNilBackgroundImageDataBuilder = backgroundImageDataBuilder;
            _backgroundImageDataBuilderImplementation = nonNilBackgroundImageDataBuilder;
        } else {
            _backgroundImageDataBuilderImplementation = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                                                             iconImageResolver:iconImageResolver];
        }
        
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

- (NSArray<id<HUBComponentModelBuilder>> *)allChildComponentModelBuilders
{
    NSMutableArray<id<HUBComponentModelBuilder>> * const builders = [NSMutableArray new];

    for (NSString * const identifier in self.childComponentIdentifierOrder) {
        id<HUBComponentModelBuilder> const builder = self.childComponentModelBuilders[identifier];
        [builders addObject:builder];
    }

    return [builders copy];
}

- (BOOL)builderExistsForChildComponentModelWithIdentifier:(NSString *)identifier
{
    return self.childComponentModelBuilders[identifier] != nil;
}

- (id<HUBComponentModelBuilder>)builderForChildComponentModelWithIdentifier:(NSString *)modelIdentifier
{
    return [self getOrCreateBuilderForChildComponentModelWithIdentifier:modelIdentifier];
}

- (void)removeBuilderForChildComponentModelWithIdentifier:(NSString *)identifier
{
    self.childComponentModelBuilders[identifier] = nil;
}

- (void)removeAllChildComponentModelBuilders
{
    [self.childComponentModelBuilders removeAllObjects];
    [self.childComponentIdentifierOrder removeAllObjects];
}

#pragma mark - HUBJSONCompatibleBuilder

- (nullable NSError *)addJSONData:(NSData *)JSONData
{
    return HUBAddJSONDataToBuilder(JSONData, self);
}

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
    
    NSString * const componentCategory = [componentModelSchema.componentCategoryPath stringFromJSONDictionary:dictionary];
    
    if (componentCategory != nil) {
        self.componentCategory = componentCategory;
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
    
    NSDictionary * const metadata = [componentModelSchema.metadataPath dictionaryFromJSONDictionary:dictionary];
    
    if (metadata != nil) {
        NSDictionary * const existingMetadata = self.metadata;
        
        if (existingMetadata != nil) {
            NSMutableDictionary * const mutableMetadata = [existingMetadata mutableCopy];
            [mutableMetadata addEntriesFromDictionary:metadata];
            self.metadata = [mutableMetadata copy];
        } else {
            self.metadata = metadata;
        }
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
    
    for (NSString * const imageIdentifier in customImageDataDictionary) {
        NSDictionary * const imageDataDictionary = customImageDataDictionary[imageIdentifier];
        
        if ([imageDataDictionary isKindOfClass:[NSDictionary class]]) {
            HUBComponentImageDataBuilderImplementation * const builder = [self getOrCreateBuilderForCustomImageDataWithIdentifier:imageIdentifier];
            [builder addDataFromJSONDictionary:imageDataDictionary];
        }
    }
    
    NSString * const iconIdentifier = [componentModelSchema.iconIdentifierPath stringFromJSONDictionary:dictionary];
    
    if (iconIdentifier != nil) {
        self.iconIdentifier = iconIdentifier;
    }
    
    NSArray * const childComponentModelDictionaries = [componentModelSchema.childComponentModelDictionariesPath valuesFromJSONDictionary:dictionary];
    
    for (NSDictionary * const childComponentModelDictionary in childComponentModelDictionaries) {
        NSString * const childModelIdentifier = [componentModelSchema.identifierPath stringFromJSONDictionary:childComponentModelDictionary];
        HUBComponentModelBuilderImplementation * const childModelBuilder = [self getOrCreateBuilderForChildComponentModelWithIdentifier:childModelIdentifier];
        [childModelBuilder addDataFromJSONDictionary:childComponentModelDictionary];
    }
}

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"HUBComponentModelBuilder with contents: %@",
            HUBSerializeToString([self buildForIndex:self.preferredIndex.unsignedIntegerValue])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    HUBComponentImageDataBuilderImplementation * const mainImageDataBuilder = [self.mainImageDataBuilderImplementation copy];
    HUBComponentImageDataBuilderImplementation * const backgroundImageDataBuilder = [self.backgroundImageDataBuilderImplementation copy];
    
    HUBComponentModelBuilderImplementation * const copy = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:self.modelIdentifier
                                                                                                                       JSONSchema:self.JSONSchema
                                                                                                                componentDefaults:self.componentDefaults
                                                                                                                iconImageResolver:self.iconImageResolver
                                                                                                             mainImageDataBuilder:mainImageDataBuilder
                                                                                                       backgroundImageDataBuilder:backgroundImageDataBuilder];
    
    copy.componentNamespace = self.componentNamespace;
    copy.componentName = self.componentName;
    copy.componentCategory = self.componentCategory;
    copy.preferredIndex = self.preferredIndex;
    copy.title = self.title;
    copy.subtitle = self.subtitle;
    copy.accessoryTitle = self.accessoryTitle;
    copy.descriptionText = self.descriptionText;
    copy.iconIdentifier = self.iconIdentifier;
    copy.targetURL = self.targetURL;
    copy.targetInitialViewModelBuilderImplementation = [self.targetInitialViewModelBuilderImplementation copy];
    copy.customData = self.customData;
    copy.loggingData = self.loggingData;
    
    for (NSString * const customImageIdentifier in self.customImageDataBuilders) {
        copy.customImageDataBuilders[customImageIdentifier] = [self.customImageDataBuilders[customImageIdentifier] copy];
    }
    
    for (NSString * const childComponentModelIdentifier in self.childComponentModelBuilders) {
        copy.childComponentModelBuilders[childComponentModelIdentifier] = [self.childComponentModelBuilders[childComponentModelIdentifier] copy];
    }
    
    [copy.childComponentIdentifierOrder addObjectsFromArray:self.childComponentIdentifierOrder];
    
    return copy;
}

#pragma mark - API

- (id<HUBComponentModel>)buildForIndex:(NSUInteger)index
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:self.componentNamespace
                                                                                                      name:self.componentName];
    
    id<HUBComponentImageData> const mainImageData = [self.mainImageDataBuilderImplementation buildWithIdentifier:nil
                                                                                                            type:HUBComponentImageTypeMain];
    
    id<HUBComponentImageData> const backgroundImageData = [self.backgroundImageDataBuilderImplementation buildWithIdentifier:nil
                                                                                                                        type:HUBComponentImageTypeBackground];
    
    NSMutableDictionary * const customImageData = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageDataBuilders) {
        HUBComponentImageDataBuilderImplementation * const builder = self.customImageDataBuilders[imageIdentifier];
        id<HUBComponentImageData> const imageData = [builder buildWithIdentifier:imageIdentifier type:HUBComponentImageTypeCustom];
        
        if (imageData != nil) {
            [customImageData setObject:imageData forKey:imageIdentifier];
        }
    }
    
    id<HUBIcon> const icon = [self buildIconForPlaceholder:NO];
    id<HUBViewModel> const targetInitialViewModel = [self buildTargetInitialViewModel];
    
    NSArray * const childComponentModels = [HUBComponentModelBuilderImplementation buildComponentModelsUsingBuilders:self.childComponentModelBuilders
                                                                                                     identifierOrder:self.childComponentIdentifierOrder];
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:self.modelIdentifier
                                                                 index:index
                                                   componentIdentifier:componentIdentifier
                                                     componentCategory:self.componentCategory
                                                                 title:self.title
                                                              subtitle:self.subtitle
                                                        accessoryTitle:self.accessoryTitle
                                                       descriptionText:self.descriptionText
                                                         mainImageData:mainImageData
                                                   backgroundImageData:backgroundImageData
                                                       customImageData:customImageData
                                                                  icon:icon
                                                             targetURL:self.targetURL
                                                targetInitialViewModel:targetInitialViewModel
                                                              metadata:self.metadata
                                                           loggingData:self.loggingData
                                                            customData:self.customData
                                                  childComponentModels:childComponentModels];
}

#pragma mark - Private utilities

- (HUBComponentImageDataBuilderImplementation *)getOrCreateBuilderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    HUBComponentImageDataBuilderImplementation * const existingBuilder = self.customImageDataBuilders[identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    HUBComponentImageDataBuilderImplementation * const newBuilder = [[HUBComponentImageDataBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                                         iconImageResolver:self.iconImageResolver];
    
    [self.customImageDataBuilders setObject:newBuilder forKey:identifier];
    
    return newBuilder;
}

- (HUBViewModelBuilderImplementation *)getOrCreateBuilderForTargetInitialViewModel
{
    // Lazily computed to avoid infinite recursion
    if (self.targetInitialViewModelBuilderImplementation == nil) {
        self.targetInitialViewModelBuilderImplementation = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:self.JSONSchema
                                                                                                       componentDefaults:self.componentDefaults
                                                                                                       iconImageResolver:self.iconImageResolver];
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
                                                                                                                             JSONSchema:self.JSONSchema
                                                                                                                      componentDefaults:self.componentDefaults
                                                                                                                      iconImageResolver:self.iconImageResolver
                                                                                                                   mainImageDataBuilder:nil
                                                                                                             backgroundImageDataBuilder:nil];
    
    [self.childComponentModelBuilders setObject:newBuilder forKey:newBuilder.modelIdentifier];
    [self.childComponentIdentifierOrder addObject:newBuilder.modelIdentifier];
    
    return newBuilder;
}

- (nullable id<HUBIcon>)buildIconForPlaceholder:(BOOL)forPlaceholder
{
    id<HUBIconImageResolver> const iconImageResolver = self.iconImageResolver;
    
    if (iconImageResolver == nil) {
        return nil;
    }
    
    NSString * const iconIdentifier = self.iconIdentifier;
    
    if (iconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBIconImplementation alloc] initWithIdentifier:iconIdentifier imageResolver:iconImageResolver isPlaceholder:forPlaceholder];
}

- (nullable id<HUBViewModel>)buildTargetInitialViewModel
{
    if (self.targetURL == nil) {
        return nil;
    }
    
    return [self.targetInitialViewModelBuilderImplementation build];
}

@end

NS_ASSUME_NONNULL_END
