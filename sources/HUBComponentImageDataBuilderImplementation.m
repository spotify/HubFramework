#import "HUBComponentImageDataBuilderImplementation.h"

#import "HUBComponentImageDataImplementation.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageDataBuilderImplementation

@synthesize style = _style;
@synthesize URL = _URL;
@synthesize iconIdentifier = _iconIdentifier;

- (HUBComponentImageDataImplementation *)build
{
    return [[HUBComponentImageDataImplementation alloc] initWithStyle:self.style
                                                                  URL:self.URL
                                                       iconIdentifier:self.iconIdentifier];
}

NS_ASSUME_NONNULL_END

@end
