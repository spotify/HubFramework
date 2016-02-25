#import <Foundation/Foundation.h>

#import "HUBComponentImageData.h"
#import "HUBComponentType.h"

NS_ASSUME_NONNULL_BEGIN

/// Contextual object used to track image downloads for components
@interface HUBComponentImageLoadingContext : NSObject

/// The index of the component that this object is for
@property (nonatomic, readonly) NSUInteger componentIndex;

/// The type of the component that this object is for
@property (nonatomic, readonly) HUBComponentType componentType;

/// The identifier of the image that this object is for
@property (nonatomic, copy, readonly, nullable) NSString *imageIdentifier;

/// The type of the image that this object is for
@property (nonatomic, readonly) HUBComponentImageType imageType;

/**
 *  Initialize an instance of this class with its required values
 *
 *  @param componentIndex The index of the component that this object is for
 *  @param componentType The type of the component that this object is for
 *  @param imageIdentifier The identifier of the image that this object is for
 *  @param imageType The type of the image that this object is for
 */
- (instancetype)initWithComponentIndex:(NSUInteger)componentIndex
                         componentType:(HUBComponentType)componentType
                       imageIdentifier:(nullable NSString *)imageIdentifier
                             imageType:(HUBComponentImageType)imageType NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
