#import "HUBImageLoader.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked image loader, for use in tests only
@interface HUBImageLoaderMock : NSObject <HUBImageLoader>

/**
 *  Return whether this image loader has been asked to load an image for a certain URL
 */
- (BOOL)hasLoadedImageForURL:(NSURL *)imageURL;

@end

NS_ASSUME_NONNULL_END
