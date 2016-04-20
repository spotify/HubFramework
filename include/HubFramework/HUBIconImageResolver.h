#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that can resolve images from icon identifiers
 *
 *  You conform to this protocol in a custom object and supply it when setting up your application's
 *  `HUBManager`. The Hub Framework uses this object whenever an image needs to be resolved from a
 *  `HUBIcon` instance.
 */
@protocol HUBIconImageResolver <NSObject>

/**
 *  Resolve an image for component icon
 *
 *  @param iconIdentifier The identifier of the icon
 *  @param size The size of the image to return
 *  @param color The color of the icon image to return
 */
- (nullable UIImage *)imageForComponentIconWithIdentifier:(NSString *)iconIdentifier
                                                     size:(CGSize)size
                                                    color:(UIColor *)color;

/**
 *  Resolve an image for a placeholder icon
 *
 *  @param iconIdentifier The identifier of the icon
 *  @param size The size of the image to return
 *  @param color The color of the icon image to return
 */
- (nullable UIImage *)imageForPlaceholderIconWithIdentifier:(NSString *)iconIdentifier
                                                       size:(CGSize)size
                                                      color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
