#import "HUBComponentModelImplementation.h"

#import "HUBComponentIdentifier.h"
#import "HUBComponentImageDataImplementation.h"
#import "HUBJSONKeys.h"
#import "HUBViewModel.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentModelImplementation

@synthesize identifier = _identifier;
@synthesize componentIdentifier = _componentIdentifier;
@synthesize contentIdentifier = _contentIdentifier;
@synthesize index = _index;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize accessoryTitle = _accessoryTitle;
@synthesize descriptionText = _descriptionText;
@synthesize mainImageData = _mainImageData;
@synthesize backgroundImageData = _backgroundImageData;
@synthesize customImageData = _customImageData;
@synthesize targetURL = _targetURL;
@synthesize targetInitialViewModel = _targetInitialViewModel;
@synthesize customData = _customData;
@synthesize loggingData = _loggingData;
@synthesize date = _date;
@synthesize childComponentModels = _childComponentModels;

- (instancetype)initWithIdentifier:(NSString *)identifier
               componentIdentifier:(HUBComponentIdentifier *)componentIdentifier
                 contentIdentifier:(nullable NSString *)contentIdentifier
                             index:(NSUInteger)index
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                    accessoryTitle:(nullable NSString *)accessoryTitle
                   descriptionText:(nullable NSString *)descriptionText
                     mainImageData:(nullable id<HUBComponentImageData>)mainImageData
               backgroundImageData:(nullable id<HUBComponentImageData>)backgroundImageData
                   customImageData:(NSDictionary<NSString *, id<HUBComponentImageData>> *)customImageData
                         targetURL:(nullable NSURL *)targetURL
            targetInitialViewModel:(nullable id<HUBViewModel>)targetInitialViewModel
                        customData:(nullable NSDictionary<NSString *, NSObject *> *)customData
                       loggingData:(nullable NSDictionary<NSString *, NSObject *> *)loggingData
                              date:(nullable NSDate *)date
              childComponentModels:(nullable NSArray<id<HUBComponentModel>> *)childComponentModels
{
    NSParameterAssert(identifier != nil);
    
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _componentIdentifier = [componentIdentifier copy];
        _contentIdentifier = [contentIdentifier copy];
        _index = index;
        _title = [title copy];
        _subtitle = [subtitle copy];
        _accessoryTitle = [accessoryTitle copy];
        _descriptionText = [descriptionText copy];
        _mainImageData = mainImageData;
        _backgroundImageData = backgroundImageData;
        _customImageData = customImageData;
        _targetURL = [targetURL copy];
        _targetInitialViewModel = targetInitialViewModel;
        _customData = customData;
        _loggingData = loggingData;
        _date = date;
        _childComponentModels = childComponentModels;
    }
    
    return self;
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> const * serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyIdentifier] = self.identifier;
    serialization[HUBJSONKeyComponent] = self.componentIdentifier.identifierString;
    serialization[HUBJSONKeyContentIdentifier] = self.contentIdentifier;
    serialization[HUBJSONKeyTitle] = self.title;
    serialization[HUBJSONKeySubtitle] = self.subtitle;
    serialization[HUBJSONKeyAccessoryTitle] = self.accessoryTitle;
    serialization[HUBJSONKeyDescription] = self.descriptionText;
    serialization[HUBJSONKeyImages] = [self serializedImageData];
    serialization[HUBJSONKeyCustom] = self.customData;
    serialization[HUBJSONKeyTarget] = [self serializedTargetData];
    serialization[HUBJSONKeyLogging] = self.loggingData;
    serialization[HUBJSONKeyDate] = [self encodedDate];
    serialization[HUBJSONKeyChildren] = [self serializedChildComponentModels];
    
    return [serialization copy];
}

#pragma mark - Private utilities

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedImageData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyMain] = [self.mainImageData serialize];
    serialization[HUBJSONKeyBackground] = [self.backgroundImageData serialize];
    
    NSMutableDictionary * const customImageDataDictionary = [NSMutableDictionary new];
    
    for (NSString * const imageIdentifier in self.customImageData.allKeys) {
        customImageDataDictionary[imageIdentifier] = [self.customImageData[imageIdentifier] serialize];
    }
    
    if (customImageDataDictionary.count > 0) {
        serialization[HUBJSONKeyCustom] = [customImageDataDictionary copy];
    }
    
    if (serialization.count == 0) {
        return nil;
    }
    
    return [serialization copy];
}

- (nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)serializedTargetData
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyURL] = self.targetURL.absoluteString;
    serialization[HUBJSONKeyView] = [self.targetInitialViewModel serialize];
    
    if (serialization.count == 0) {
        return nil;
    }
                  
    return [serialization copy];
}

- (nullable NSArray<NSDictionary<NSString *, NSObject<NSCoding> *> *> *)serializedChildComponentModels
{
    NSArray<id<HUBComponentModel>> * const childComponentModels = self.childComponentModels;
    
    if (childComponentModels.count == 0) {
        return nil;
    }
    
    NSMutableArray<NSDictionary<NSString *, NSObject<NSCoding> *> *> * const serializedModels = [NSMutableArray new];
    
    for (id<HUBComponentModel> const model in childComponentModels) {
        [serializedModels addObject:[model serialize]];
    }
    
    return [serializedModels copy];
}

- (nullable NSString *)encodedDate
{
    NSDate * const date = self.date;
    
    if (date == nil) {
        return nil;
    }
    
    return [HUBDateFormatterCreateWithDefaultFormat() stringFromDate:date];
}

@end

NS_ASSUME_NONNULL_END
