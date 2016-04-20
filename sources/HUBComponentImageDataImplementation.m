#import "HUBComponentImageDataImplementation.h"

#import "HUBJSONKeys.h"
#import "HUBIcon.h"

NS_ASSUME_NONNULL_BEGIN

NSString *HUBComponentImageStyleStringFromStyle(HUBComponentImageStyle style) {
    switch (style) {
        case HUBComponentImageStyleNone:
            return @"none";
        case HUBComponentImageStyleRectangular:
            return @"rectangular";
        case HUBComponentImageStyleCircular:
            return @"circular";
    }
}

@implementation HUBComponentImageDataImplementation

@synthesize identifier = _identifier;
@synthesize type = _type;
@synthesize style = _style;
@synthesize URL = _URL;
@synthesize placeholderIcon = _placeholderIcon;
@synthesize localImage = _localImage;

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                              type:(HUBComponentImageType)type
                             style:(HUBComponentImageStyle)style
                               URL:(nullable NSURL *)URL
                   placeholderIcon:(nullable id<HUBIcon>)placeholderIcon
                        localImage:(nullable UIImage *)localImage
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _type = type;
        _style = style;
        _URL = [URL copy];
        _placeholderIcon = placeholderIcon;
        _localImage = localImage;
    }
    
    return self;
}

#pragma mark - HUBSerializable

- (NSDictionary<NSString *, NSObject<NSCoding> *> *)serialize
{
    NSMutableDictionary<NSString *, NSObject<NSCoding> *> * const serialization = [NSMutableDictionary new];
    serialization[HUBJSONKeyStyle] = HUBComponentImageStyleStringFromStyle(self.style);
    serialization[HUBJSONKeyURI] = self.URL.absoluteString;
    serialization[HUBJSONKeyPlaceholder] = self.placeholderIcon.identifier;
    
    return [serialization copy];
}

@end

NS_ASSUME_NONNULL_END
