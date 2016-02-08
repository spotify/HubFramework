#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize iconIdentifier = _iconIdentifier;

- (instancetype)initWithStyle:(HUBComponentImageStyle)style URL:(nullable NSURL *)URL iconIdentifier:(nullable NSString *)iconIdentifier
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _style = style;
    _URL = [URL copy];
    _iconIdentifier = [iconIdentifier copy];
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
