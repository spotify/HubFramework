#import "HUBDefaultImageLoaderFactory.h"
#import "HUBDefaultImageLoader.h"

@implementation HUBDefaultImageLoaderFactory

- (id<HUBImageLoader>)createImageLoader
{
    return [[HUBDefaultImageLoader alloc] initWithSession:[NSURLSession sharedSession]];
}

@end
