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
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *mainImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *backgroundImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentImageDataBuilderImplementation *> *customImageDataBuilders;
@property (nonatomic, strong, nullable) HUBViewModelBuilderImplementation *targetInitialViewModelBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableArray<HUBComponentModelBuilderImplementation *> *childComponentModelBuilders;

@end

@implementation HUBComponentModelBuilderImplementation

@synthesize modelIdentifier = _modelIdentifier;
@synthesize componentIdentifier = _componentIdentifier;
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

- (instancetype)initWithModelIdentifier:(NSString *)modelIdentifier featureIdentifier:(NSString *)featureIdentifier
{
    NSParameterAssert(modelIdentifier != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _modelIdentifier = [modelIdentifier copy];
    _featureIdentifier = [featureIdentifier copy];
    _mainImageDataBuilderImplementation = [HUBComponentImageDataBuilderImplementation new];
    _backgroundImageDataBuilderImplementation = [HUBComponentImageDataBuilderImplementation new];
    _customImageDataBuilders = [NSMutableDictionary new];
    _childComponentModelBuilders = [NSMutableArray new];
    
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

- (id<HUBComponentModelBuilder>)createBuilderForChildComponentModelWithIdentifier:(NSString *)modelIdentifier
{
    return [self createBuilderForChildComponentModelWithIdentifier:modelIdentifier atIndex:self.childComponentModelBuilders.count];
}

- (id<HUBComponentModelBuilder>)builderForChildComponentModelAtIndex:(NSUInteger)childIndex reuseExisting:(BOOL)reuseExisting
{
    if (childIndex >= self.childComponentModelBuilders.count) {
        return [self createBuilderForChildComponentModelWithIdentifier:nil atIndex:self.childComponentModelBuilders.count];
    }
    
    if (!reuseExisting) {
        return [self createBuilderForChildComponentModelWithIdentifier:nil atIndex:childIndex];
    }
    
    return [self.childComponentModelBuilders objectAtIndex:childIndex];
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
        self.componentIdentifier = [[HUBComponentIdentifier alloc] initWithString:componentIdentifierString];
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
        NSString * const modelIdentifier = [componentModelSchema.identifierPath stringFromJSONDictionary:childComponentModelDictionary];
        HUBComponentModelBuilderImplementation * const builder = [self createBuilderForChildComponentModelWithIdentifier:modelIdentifier
                                                                                                                 atIndex:self.childComponentModelBuilders.count];
        
        [builder addDataFromJSONDictionary:childComponentModelDictionary usingSchema:schema];
    }
}

#pragma mark - API

- (HUBComponentModelImplementation *)build
{
    id<HUBComponentImageData> const mainImageData = [self.mainImageDataBuilderImplementation build];
    id<HUBComponentImageData> const backgroundImageData = [self.backgroundImageDataBuilderImplementation build];
    
    NSMutableDictionary * const customImageData = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageDataBuilders.allKeys) {
        id<HUBComponentImageData> const imageData = [[self.customImageDataBuilders objectForKey:imageIdentifier] build];
        
        if (imageData != nil) {
            [customImageData setObject:imageData forKey:imageIdentifier];
        }
    }
    
    id<HUBViewModel> const targetInitialViewModel = [self.targetInitialViewModelBuilderImplementation build];
    
    NSMutableArray * const childComponentModels = [NSMutableArray new];
    
    for (HUBComponentModelBuilderImplementation * const builder in self.childComponentModelBuilders) {
        [childComponentModels addObject:[builder build]];
    }
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:self.modelIdentifier
                                                   componentIdentifier:self.componentIdentifier
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
        self.targetInitialViewModelBuilderImplementation = [[HUBViewModelBuilderImplementation alloc] initWithFeatureIdentifier:self.featureIdentifier];
    }
    
    return (HUBViewModelBuilderImplementation *)self.targetInitialViewModelBuilderImplementation;
}

- (HUBComponentModelBuilderImplementation *)createBuilderForChildComponentModelWithIdentifier:(nullable NSString *)modelIdentifier atIndex:(NSUInteger)childIndex
{
    if (modelIdentifier == nil) {
        modelIdentifier = [self.modelIdentifier stringByAppendingFormat:@"-child-%lu", (unsigned long)childIndex];
    }
    
    HUBComponentModelBuilderImplementation * const builder = [[HUBComponentModelBuilderImplementation alloc] initWithModelIdentifier:modelIdentifier
                                                                                                                   featureIdentifier:self.featureIdentifier];
    
    [self.childComponentModelBuilders insertObject:builder atIndex:childIndex];
    
    return builder;
}

@end

NS_ASSUME_NONNULL_END
