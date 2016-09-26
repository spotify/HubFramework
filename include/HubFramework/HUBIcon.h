#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of an icon object
 *
 *  An icon is not renderable in of itself, but rather acts as a container for icon information, which
 *  can be materialized into an image of any size. Images are resolved using the `HUBIconImageResolver`
 *  passed when setting up `HUBManager`.
 */
@protocol HUBIcon <NSObject>

/// The identifier of the icon. Can be used for custom image resolving.
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 *  Convert the icon into an image of a given size and color
 *
 *  @param size The size of the image to return
 *  @param color The color of the icon image to return
 */
- (nullable UIImage *)imageWithSize:(CGSize)size color:(UIColor *)color NS_SWIFT_NAME(imageWith(size:color:));

@end

NS_ASSUME_NONNULL_END
