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
@synthesize imageData = _imageData;
@synthesize targetURL = _targetURL;
@synthesize customData = _customData;
@synthesize loggingData = _loggingData;
@synthesize date = _date;

- (instancetype)initWithIdentifier:(NSString *)identifier componentIdentifier:(NSString *)componentIdentifier contentIdentifier:(nullable NSString *)contentIdentifier title:(nullable NSString *)title subtitle:(nullable NSString *)subtitle accessoryTitle:(nullable NSString *)accessoryTitle descriptionText:(nullable NSString *)descriptionText imageData:(nullable HUBComponentImageDataImplementation *)imageData targetURL:(nullable NSURL *)targetURL customData:(nullable NSDictionary<NSString *, NSObject *> *)customData loggingData:(nullable NSDictionary<NSString *, NSObject<NSCoding> *> *)loggingData date:(nullable NSDate *)date
{
    NSParameterAssert(identifier != nil);
    NSParameterAssert(componentIdentifier != nil);
    
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
    _imageData = imageData;
    _targetURL = targetURL;
    _customData = customData;
    _loggingData = loggingData;
    _date = date;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
