#import "HUBComponentImageLoadingContext.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentImageLoadingContext

- (instancetype)initWithComponentIndex:(NSUInteger)componentIndex
                         componentType:(HUBComponentType)componentType
                       imageIdentifier:(nullable NSString *)imageIdentifier
                             imageType:(HUBComponentImageType)imageType
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _componentIndex = componentIndex;
    _componentType = componentType;
    _imageIdentifier = imageIdentifier;
    _imageType = imageType;
    
    return self;
}

@end

NS_ASSUME_NONNULL_END
