#import <UIKit/UIKit.h>

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
 *  have either have a non-nil `URL` or `iconIdentifier` property.
 */
@protocol HUBComponentImageDataBuilder <NSObject>

/// The style that the image should be rendered in
@property (nonatomic) HUBComponentImageStyle style;

/// Any HTTP URL of a remote image that should be downloaded and then rendered
@property (nonatomic, copy, nullable) NSURL *URL;

/// Any local image that should be used, either as a placeholder or a permanent image
@property (nonatomic, copy, nullable) UIImage *localImage;

/// Any identifier of an icon that should be used with the image, either as a placeholder or permanent image
@property (nonatomic, copy, nullable) NSString *iconIdentifier;

@end

NS_ASSUME_NONNULL_END
