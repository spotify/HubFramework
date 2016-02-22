#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataImplementation

@synthesize identifier = _identifier;
@synthesize style = _style;
@synthesize URL = _URL;
@synthesize iconIdentifier = _iconIdentifier;

- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                             style:(HUBComponentImageStyle)style
                               URL:(nullable NSURL *)URL
                    iconIdentifier:(nullable NSString *)iconIdentifier
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _identifier = [identifier copy];
    _style = style;
    _URL = [URL copy];
    _iconIdentifier = [iconIdentifier copy];
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
