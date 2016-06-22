#import <UIKit/UIKit.h>

#import "HUBJSONCompatibleBuilder.h"
#import "HUBComponentImageData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API for a builder that builds image data objects
 *
 *  This builder acts like a mutable model counterpart for `HUBComponentImageData`, with the key
 *  difference that they are not related by inheritance.
 *
 *  All properties are briefly documented as part of this protocol, but for more extensive
 *  documentation and use case examples, see the full documentation in the `HUBComponentImageData`
 *  protocol definition.
 *
 *  In order to successfully build an image data object (and not return nil), the builder must
 *  have either have a non-nil `URL`, `placeholderIconIdentifier` or `localImage` property.
 */
@protocol HUBComponentImageDataBuilder <HUBJSONCompatibleBuilder>

/// The style that the image should be rendered in
@property (nonatomic) HUBComponentImageStyle style;

/// Any HTTP URL of a remote image that should be downloaded and then rendered
@property (nonatomic, copy, nullable) NSURL *URL;

/**
 *  Any identifier of a placeholder icon that should be used while a remote image is downloaded
 *
 *  The image for the icon will be resolved using the application's `HUBIconImageResolver`.
 */
@property (nonatomic, copy, nullable) NSString *placeholderIconIdentifier;

/// Any local image that should be used, either as a placeholder or a permanent image
@property (nonatomic, strong, nullable) UIImage *localImage;

@end

NS_ASSUME_NONNULL_END
