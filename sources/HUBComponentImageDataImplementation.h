#import "HUBComponentImageData.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentImageData` API
@interface HUBComponentImageDataImplementation : NSObject <HUBComponentImageData>

/**
 *  Initialize an instance of this class with its possible values
 *
 *  @param style The style the image should be rendered in
 *  @param URL Any HTTP URL of a remote image that should be downloaded and then rendered
 *  @param iconIdentifier Any identifier of an icon that should be used with the image
 *
 *  For more information about these parameters and their corresponding properties, see their
 *  documentation in `HUBComponentImageData`.
 */
- (instancetype)initWithStyle:(HUBComponentImageStyle)style
                          URL:(nullable NSURL *)URL
               iconIdentifier:(nullable NSString *)iconIdentifier NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
