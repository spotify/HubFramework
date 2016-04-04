#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataImplementation

@synthesize identifier = _identifier;
@synthesize type = _type;
@synthesize style = _style;
@synthesize URL = _URL;
@synthesize localImage = _localImage;
@synthesize iconIdentifier = _iconIdentifier;

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                              type:(HUBComponentImageType)type
                             style:(HUBComponentImageStyle)style
                               URL:(nullable NSURL *)URL
                        localImage:(nullable UIImage *)localImage
                    iconIdentifier:(nullable NSString *)iconIdentifier
{
    self = [super init];
    
    if (self) {
        _identifier = [identifier copy];
        _type = type;
        _style = style;
        _URL = [URL copy];
        _localImage = localImage;
        _iconIdentifier = [iconIdentifier copy];
    }
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
