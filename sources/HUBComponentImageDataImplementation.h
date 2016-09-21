#import "HUBAutoEquatable.h"
#import "HUBComponentImageData.h"
#import "HUBHeaderMacros.h"

@protocol HUBIcon;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentImageData` API
@interface HUBComponentImageDataImplementation : HUBAutoEquatable <HUBComponentImageData>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param identifier Any identifier for the image (only non-`nil` for custom images)
 *  @param type The type of the image. See `HUBComponentImageType` for more information.
 *  @param URL Any HTTP URL of a remote image that should be downloaded and then rendered
 *  @param placeholderIcon Any icon to use as a placeholder before a remote image has been downloaded
 *  @param localImage Any local image that should be rendered
 *
 *  For more information about these parameters and their corresponding properties, see their
 *  documentation in `HUBComponentImageData`.
 */
- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                              type:(HUBComponentImageType)type
                               URL:(nullable NSURL *)URL
                   placeholderIcon:(nullable id<HUBIcon>)placeholderIcon
                        localImage:(nullable UIImage *)localImage HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
