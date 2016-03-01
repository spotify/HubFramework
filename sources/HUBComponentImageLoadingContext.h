#import <Foundation/Foundation.h>

#import "HUBComponentImageData.h"
#import "HUBComponentType.h"

NS_ASSUME_NONNULL_BEGIN

/// Contextual object used to track image downloads for components
@interface HUBComponentImageLoadingContext : NSObject

/// The type of the image that this object is for
@property (nonatomic, readonly) HUBComponentImageType imageType;

/// The identifier of the image that this object is for
@property (nonatomic, copy, readonly, nullable) NSString *imageIdentifier;

/// The identifier of the wrapper for the component that the image is for
@property (nonatomic, copy, readonly) NSUUID *wrapperIdentifier;

/// Any index of a child component that the image is for
@property (nonatomic, copy, readonly, nullable) NSNumber *childIndex;

/**
 *  Initialize an instance of this class with its required values
 *
 *  @param imageType The type of the image that this object is for
 *  @param imageIdentifier Any identifier for the image that this object is for
 *  @param wrapperIdentifier The identifier of the wrapper for the component that the image is for
 *  @param childIndex Any index of a child component that the image is for
 */
- (instancetype)initWithImageType:(HUBComponentImageType)imageType
                  imageIdentifier:(nullable NSString *)imageIdentifier
                wrapperIdentifier:(NSUUID *)wrapperIdentifier
                       childIndex:(nullable NSNumber *)childIndex NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
