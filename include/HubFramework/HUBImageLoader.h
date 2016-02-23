#import <UIKit/UIKit.h>

@protocol HUBImageLoader;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBImageLoader`
 *
 *  You don't conform to this protocol yourself. Instead, the Hub Framework will assign an internal object
 *  that conforms to this protocol as the delegate of any image loader. You use the methods defined in this
 *  protocol to communicate an image loader's outcomes back to the framework.
 */
@protocol HUBImageLoaderDelegate <NSObject>

/**
 *  Notify the Hub Framework that an image loader finished loading an image
 *
 *  @param imageLoader The image loader that finished loading
 *  @param image The image that was loaded
 *  @param imageURL The URL of the image that was loaded
 */
- (void)imageLoader:(id<HUBImageLoader>)imageLoader didLoadImage:(UIImage *)image forURL:(NSURL *)imageURL;

/**
 *  Notify the Hub Framework that an image loader failed to load an image because of an error
 *
 *  @param imageLoader The image loader that failed loading
 *  @param imageURL The URL of the image that failed to load
 *  @param error The error that was encountered
 */
- (void)imageLoader:(id<HUBImageLoader>)imageLoader didFailLoadingImageForURL:(NSURL *)imageURL error:(NSError *)error;

@end

/**
 *  Protocol that objects that load images on behalf of the Hub Framework conform to
 *
 *  The Hub Framework uses an image loader to load images for components which models contain image data, when the
 *  component is about to be displayed on the screen. The framework itself does not employ any caching on images, so
 *  it's up to each implementation of this protocol to handle that.
 *
 *  See also `HUBImageLoaderFactory` which is used to create instances conforming to this protocol.
 */
@protocol HUBImageLoader <NSObject>

/// The image loader's delegate. Don't assign this property yourself, it will be set by the Hub Framework.
@property (nonatomic, weak, nullable) id<HUBImageLoaderDelegate> delegate;

/**
 *  Load an image from a certain URL
 *
 *  @param imageURL The URL of the image to load
 *  @param targetSize The target size of the image. It's up to the image loader to either resize the image accordingly,
 *         (if the loaded image has an incorrect size), or ignore this parameter.
 */
- (void)loadImageForURL:(NSURL *)imageURL targetSize:(CGSize)targetSize;

@end

NS_ASSUME_NONNULL_END
