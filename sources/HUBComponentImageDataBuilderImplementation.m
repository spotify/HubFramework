#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataBuilderImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize iconIdentifier = _iconIdentifier;

- (nullable HUBComponentImageDataImplementation *)build
{
    if (self.URL == nil && self.iconIdentifier == nil) {
        return nil;
    }
    
    return [[HUBComponentImageDataImplementation alloc] initWithStyle:self.style
                                                                  URL:self.URL
                                                       iconIdentifier:self.iconIdentifier];
}

NS_ASSUME_NONNULL_END

@end
