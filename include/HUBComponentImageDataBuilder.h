#import <Foundation/Foundation.h>

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
 */
@protocol HUBComponentImageDataBuilder <NSObject>

/// The style that the image should be rendered in
@property (nonatomic) HUBComponentImageStyle style;

/// Any HTTP URL of a remote image that should be downloaded and then rendered
@property (nonatomic, copy, nullable) NSURL *URL;

/// Any identifier of an icon that should be used with the image, either as a placeholder or permanent image
@property (nonatomic, copy, nullable) NSString *iconIdentifier;

@end

NS_ASSUME_NONNULL_END
