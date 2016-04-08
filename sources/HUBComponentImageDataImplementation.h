#import "HUBComponentImageData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Return a string representation of a `HUBComponentImageStyle` value
 *
 *  @param style The image style value to convert to a string
 */
extern NSString *HUBComponentImageStyleStringFromStyle(HUBComponentImageStyle style);

/// Concrete implementation of the `HUBComponentImageData` API
@interface HUBComponentImageDataImplementation : NSObject <HUBComponentImageData>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier Any identifier for the image (only non-`nil` for custom images)
 *  @param type The type of the image. See `HUBComponentImageType` for more information.
 *  @param style The style the image should be rendered in
 *  @param URL Any HTTP URL of a remote image that should be downloaded and then rendered
 *  @param localImage Any local image that should be rendered
 *  @param iconIdentifier Any identifier of an icon that should be used with the image
 *
 *  For more information about these parameters and their corresponding properties, see their
 *  documentation in `HUBComponentImageData`.
 */
- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                              type:(HUBComponentImageType)type
                             style:(HUBComponentImageStyle)style
                               URL:(nullable NSURL *)URL
                        localImage:(nullable UIImage *)localImage
                    iconIdentifier:(nullable NSString *)iconIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
