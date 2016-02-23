#import "HUBComponentImageLoadingContext.h"

@implementation HUBComponentImageLoadingContext

- (instancetype)initWithComponentIndex:(NSUInteger)componentIndex imageIdentifier:(nullable NSString *)imageIdentifier imageType:(HUBComponentImageType)imageType
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _componentIndex = componentIndex;
    _imageIdentifier = imageIdentifier;
    _imageType = imageType;
    
    return self;
}

@end
