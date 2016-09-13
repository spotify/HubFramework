#import "HUBComponentTargetBuilder.h"
#import "HUBHeaderMacros.h"

@protocol HUBJSONSchema;
@protocol HUBIconImageResolver;
@protocol HUBComponentTarget;
@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentTargetBuilder` API
@interface HUBComponentTargetBuilderImplementation : NSObject <HUBComponentTargetBuilder, NSCopying>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentDefaults The default component values for this instance of the Hub Framework
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 *  @param actionIdentifiers The initial action identifiers that the builder should contain
 */
- (instancetype)initWithJSONSchema:(id<HUBJSONSchema>)JSONSchema
                 componentDefaults:(HUBComponentDefaults *)componentDefaults
                 iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                 actionIdentifiers:(nullable NSOrderedSet<HUBIdentifier *> *)actionIdentifiers HUB_DESIGNATED_INITIALIZER;

/// Build a component target instance from the data contained in this builder
- (id<HUBComponentTarget>)build;

@end

NS_ASSUME_NONNULL_END
