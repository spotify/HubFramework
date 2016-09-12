#import "HUBComponentModelBuilderImplementation.h"
#import "HUBComponentShowcaseShapshotGenerator.h"

@class HUBComponentRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Component model builder subclass that is also a showcase snapshot generator
@interface HUBComponentModelBuilderShowcaseSnapshotGenerator : HUBComponentModelBuilderImplementation <HUBComponentShowcaseSnapshotGenerator>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentRegistry The component registry used in this instance of the Hub Framework
 *  @param componentDefaults The default component values that should be used as initial values for this builder
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 *  @param mainImageDataBuilder Any specific image data builder that the object should use for its main image.
 *  @param backgroundImageDataBuilder Any specific image data builder that the object should use for its background image.
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
              mainImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)mainImageDataBuilder
        backgroundImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)backgroundImageDataBuilder;

@end

NS_ASSUME_NONNULL_END
