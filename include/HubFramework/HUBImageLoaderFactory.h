#import <Foundation/Foundation.h>

@protocol HUBImageLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol that objects that create image loaders for use with the Hub Framework conform to
 *
 *  You conform to this protocol in a custom object and pass that object when setting up `HUBManager`. The
 *  Hub Framework will then use the factory to create an image loader for each view controller that it creates.
 *
 *  In case you don't supply your own image loader factory, the default `HUBDefaultImageLoaderFactory` is used.
 *
 *  See `HUBImageLoader` for more information.
 */
@protocol HUBImageLoaderFactory <NSObject>

/**
 *  Create an image loader
 *
 *  This will be called every time that a view controller is created by the Hub Framework
 */
- (id<HUBImageLoader>)createImageLoader;

@end

NS_ASSUME_NONNULL_END
