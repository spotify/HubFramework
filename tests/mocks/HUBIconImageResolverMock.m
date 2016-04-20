#import "HUBIconImageResolverMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBIconImageResolverMock

- (nullable UIImage *)imageForComponentIconWithIdentifier:(NSString *)iconIdentifier size:(CGSize)size color:(UIColor *)color
{
    return self.imageForComponentIcons;
}

- (nullable UIImage *)imageForPlaceholderIconWithIdentifier:(NSString *)iconIdentifier size:(CGSize)size color:(UIColor *)color
{
    return self.imageForPlaceholderIcons;
}

@end

NS_ASSUME_NONNULL_END
