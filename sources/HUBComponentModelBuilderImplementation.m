#import "HUBComponentModelBuilderImplementation.h"

#import "HUBComponentModelImplementation.h"
#import "HUBComponentImageDataBuilderImplementation.h"
#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderImplementation ()

@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *mainImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *backgroundImageDataBuilderImplementation;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HUBComponentImageDataBuilderImplementation *> *customImageDataBuilders;

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

- (instancetype)initWithModelIdentifier:(NSString *)modelIdentifier
{
    NSParameterAssert(modelIdentifier != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _modelIdentifier = modelIdentifier;
    _mainImageDataBuilderImplementation = [HUBComponentImageDataBuilderImplementation new];
    _backgroundImageDataBuilderImplementation = [HUBComponentImageDataBuilderImplementation new];
    _customImageDataBuilders = [NSMutableDictionary new];
    
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

- (BOOL)builderExistsForCustomImageDataWithIdentifier:(NSString *)identifier
{
    return [self.customImageDataBuilders objectForKey:identifier] != nil;
}

- (id<HUBComponentImageDataBuilder>)builderForCustomImageDataWithIdentifier:(NSString *)identifier
{
    id<HUBComponentImageDataBuilder> const existingBuilder = [self.customImageDataBuilders objectForKey:identifier];
    
    if (existingBuilder != nil) {
        return existingBuilder;
    }
    
    id<HUBComponentImageDataBuilder> const newBuilder = [HUBComponentImageDataBuilderImplementation new];
    [self.customImageDataBuilders setObject:newBuilder forKey:identifier];
    return newBuilder;
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
                                                            customData:self.customData
                                                           loggingData:self.loggingData
                                                                  date:self.date];
}

@end

NS_ASSUME_NONNULL_END
