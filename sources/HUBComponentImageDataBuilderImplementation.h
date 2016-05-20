#import "HUBComponentImageDataBuilder.h"
#import "HUBJSONCompatibleBuilder.h"
#import "HUBHeaderMacros.h"

@protocol HUBComponentImageDataJSONSchema;
@protocol HUBIconImageResolver;
@class HUBComponentImageDataImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentImageDataBuilder` API
@interface HUBComponentImageDataBuilderImplementation : NSObject <HUBComponentImageDataBuilder, HUBJSONCompatibleBuilder, NSCopying>

/**
 *  Initialize an instance of this class with a JSON schema
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

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

@end

NS_ASSUME_NONNULL_END
