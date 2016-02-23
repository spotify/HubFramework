#import "HUBImageLoaderFactoryMock.h"
#import "HUBImageLoaderMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBImageLoaderFactoryMock

- (id<HUBImageLoader>)createImageLoader
{
    return [HUBImageLoaderMock new];
}

@end

NS_ASSUME_NONNULL_END
