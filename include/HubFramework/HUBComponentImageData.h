#import <UIKit/UIKit.h>
#import "HUBSerializable.h"

NS_ASSUME_NONNULL_BEGIN

/// Enum describing various styles that an image can be rendered in
typedef NS_ENUM(NSInteger, HUBComponentImageStyle) {
    /// No image should be rendered
    HUBComponentImageStyleNone,
    /// The image should be rendered in a rectangular shape
    HUBComponentImageStyleRectangular,
    /// The image should be rendered in a circular shape
    HUBComponentImageStyleCircular
};

/// Enum describing various types of component images
typedef NS_ENUM(NSInteger, HUBComponentImageType) {
    /// The main image of a component. See `HUBComponentModel.mainImageData` for more information.
    HUBComponentImageTypeMain,
    /// The background image of a component. See `HUBComponentModel.backgroundImageData` for more information.
    HUBComponentImageTypeBackground,
    /// A custom image for a component. See `HUBComponentModel.customImageData` for more information.
    HUBComponentImageTypeCustom
};

/**
 *  Protocol defining the public API of an object that describes image data for a Component in the Hub Framework
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create implementations of it for you
 *  based on the data supplied to a `HUBComponentModelBuilder` or through JSON data.
 */
@protocol HUBComponentImageData <HUBSerializable>

/**
 *  Any identifier for the image
 *
 *  This will always be `nil` for default images (main and background). For custom images, this property contains the
 *  same identifier as its key in the `customImageData` dictionary of its `HUBComponentModel`.
 */
@property (nonatomic, copy, readonly, nullable) NSString *identifier;

/**
 *  The type of the image
 *
 *  If the type is `HUBComponentImageTypeCustom`, the `identifier` property will contain the custom identifier of the
 *  image. See `HUBComponentImageType` for more information.
 */
@property (nonatomic, readonly) HUBComponentImageType type;

/**
 *  The style that the image should be rendered in
 *
 *  If HUBComponentImageStyleNone, that indicates to a component that no image should actually be rendered. This might
 *  be the case of the API user wishes to use the image for another purpose than rendering in a component (such as
 *  providing it to an external data API user). See `HUBComponentImageStyle` for more information.
 */
@property (nonatomic, readonly) HUBComponentImageStyle style;

/**
 *  Any HTTP URL of a remote image that should be downloaded and then rendered
 *
 *  The Hub Framework will take care of the image downloading itself, and will notify a component once that operation is
 *  completed, so a component normally doesn't have to interact with this property itself.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *URL;

/**
 *  Any local image that should be used either as a placeholder image before the actual image has been dowloaded, or as a
 *  permanent image.
 */
@property (nonatomic, strong, readonly, nullable) UIImage *localImage;

/**
 *  Any identifier of an icon that should be used either as a placeholder image before the actual image has been downloaded,
 *  or as a permanent image.
 *
 *  It's up to a component how to enterpret this identifier, and turn it into an actual `UIImage` that can be rendered.
 */
@property (nonatomic, copy, readonly, nullable) NSString *iconIdentifier;

@end

NS_ASSUME_NONNULL_END
