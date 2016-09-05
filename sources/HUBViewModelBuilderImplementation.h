#import "HUBViewModelBuilder.h"
#import "HUBHeaderMacros.h"

@protocol HUBJSONSchema;
@protocol HUBIconImageResolver;
@protocol HUBViewModel;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelBuilder` API
@interface HUBViewModelBuilderImplementation : NSObject <HUBViewModelBuilder, NSCopying>

/**
 *  Initialize an instance of this class with a feature identifier
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentDefaults The default values to use for component model builders
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver HUB_DESIGNATED_INITIALIZER;

/**
 *  Build a view model instance from the data contained in this builder
 */
- (id<HUBViewModel>)build;

@end

NS_ASSUME_NONNULL_END
