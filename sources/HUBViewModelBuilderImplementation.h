#import "HUBViewModelBuilder.h"
#import "HUBJSONCompatibleBuilder.h"
#import "HUBHeaderMacros.h"

@protocol HUBJSONSchema;
@protocol HUBIconImageResolver;
@class HUBComponentDefaults;
@class HUBViewModelImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelBuilder` API
@interface HUBViewModelBuilderImplementation : NSObject <HUBViewModelBuilder, HUBJSONCompatibleBuilder, NSCopying>

/**
 *  Initialize an instance of this class with a feature identifier
 *
 *  @param featureIdentifier The identifier of the feature that this builder is for
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentDefaults The default values to use for component model builders
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier
                               JSONSchema:(id<HUBJSONSchema>)JSONSchema
                        componentDefaults:(HUBComponentDefaults *)componentDefaults
                        iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

/**
 *  Build an instance of `HUBViewModelImplementation` from the data contained in this builder
 */
- (HUBViewModelImplementation *)build;

@end

NS_ASSUME_NONNULL_END
