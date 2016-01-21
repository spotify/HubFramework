#import "HUBComponentModelBuilderImplementation.h"

#import "HUBComponentModelImplementation.h"
#import "HUBComponentImageDataBuilderImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentModelBuilderImplementation ()

@property (nonatomic, strong, readonly) HUBComponentImageDataBuilderImplementation *imageDataBuilder;

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

- (instancetype)initWithModelIdentifier:(NSString *)modelIdentifier componentIdentifier:(NSString *)componentIdentifier
{
    NSParameterAssert(modelIdentifier != nil);
    NSParameterAssert(componentIdentifier != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _modelIdentifier = modelIdentifier;
    _componentIdentifier = componentIdentifier;
    
    return self;
}

#pragma mark - HUBComponentModelBuilder

- (id<HUBComponentImageDataBuilder>)imageData
{
    return self.imageDataBuilder;
}

#pragma mark - API

- (HUBComponentModelImplementation *)build
{
    HUBComponentImageDataImplementation * const imageData = [self.imageDataBuilder build];
    
    return [[HUBComponentModelImplementation alloc] initWithIdentifier:self.modelIdentifier
                                                   componentIdentifier:self.componentIdentifier
                                                     contentIdentifier:self.contentIdentifier
                                                                 title:self.title
                                                              subtitle:self.subtitle
                                                        accessoryTitle:self.accessoryTitle
                                                       descriptionText:self.descriptionText
                                                             imageData:imageData
                                                             targetURL:self.targetURL
                                                            customData:self.customData
                                                           loggingData:self.loggingData
                                                                  date:self.date];
}

@end

NS_ASSUME_NONNULL_END
