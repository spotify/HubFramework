#import "HUBComponentModelImplementation.h"

#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentModelImplementation

@synthesize identifier = _identifier;
@synthesize componentIdentifier = _componentIdentifier;
@synthesize contentIdentifier = _contentIdentifier;
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

- (instancetype)initWithIdentifier:(NSString *)identifier
               componentIdentifier:(nullable NSString *)componentIdentifier
                 contentIdentifier:(nullable NSString *)contentIdentifier
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
                       loggingData:(nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)loggingData
                              date:(nullable NSDate *)date
{
    NSParameterAssert(identifier != nil);
    
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifier = identifier;
    _componentIdentifier = componentIdentifier;
    _contentIdentifier = contentIdentifier;
    _title = title;
    _subtitle = subtitle;
    _accessoryTitle = accessoryTitle;
    _descriptionText = descriptionText;
    _mainImageData = mainImageData;
    _backgroundImageData = backgroundImageData;
    _customImageData = customImageData;
    _targetURL = targetURL;
    _targetInitialViewModel = targetInitialViewModel;
    _customData = customData;
    _loggingData = loggingData;
    _date = date;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
