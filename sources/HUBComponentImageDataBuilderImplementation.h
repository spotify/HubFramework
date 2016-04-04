#import "HUBComponentImageDataBuilder.h"
#import "HUBJSONCompatibleBuilder.h"

@protocol HUBComponentImageDataJSONSchema;
@class HUBComponentImageDataImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentImageDataBuilder` API
@interface HUBComponentImageDataBuilderImplementation : NSObject <HUBComponentImageDataBuilder, HUBJSONCompatibleBuilder>

/**
 *  Initialize an instance of this class with a JSON schema
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema NS_DESIGNATED_INITIALIZER;

/**
 *  Build an instance of `HUBComponentImageDataImplementation` from the data contained in this builder
 *
 *  @param identifier Any identifier that the produced image data should have
 *  @param type The type of the image. See `HUBComponentImageType` for more information.
 *
 *  If the builder has neither an `URL` or `iconIdentifier` associated with it, nil will be returned.
 */
- (nullable HUBComponentImageDataImplementation *)buildWithIdentifier:(nullable NSString *)identifier
                                                                 type:(HUBComponentImageType)type;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
