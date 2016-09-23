#import "HUBImageLoaderFactory.h"

/**
 *  Default image loader factory used for applications that do not define their own
 *
 *  This image loader factory is used if `nil` is passed as `imageLoaderFactory` when setting
 *  up the application's `HUBManager`. It produces instances of `HUBDefaultImageLoader`, so see
 *  the documentation for that class for more information.
 *
 *  In case you need more powerful image loader features you might want to either implement
 *  your own factory using `HUBImageLoaderFactory`, or adding a wrapper for that protocol around
 *  an image loading library.
 */
@interface HUBDefaultImageLoaderFactory : NSObject <HUBImageLoaderFactory>

@end
