#import "HUBComponentModelBuilder.h"
#import "HUBHeaderMacros.h"
#import "HUBComponentType.h"

@protocol HUBJSONSchema;
@protocol HUBIconImageResolver;
@protocol HUBComponentModel;
@class HUBComponentDefaults;
@class HUBComponentImageDataBuilderImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentModelBuilder` API
@interface HUBComponentModelBuilderImplementation : NSObject <HUBComponentModelBuilder, NSCopying>

/**
 *  Build an array of component models from a collection of builders
 *
 *  @param builders The builders to use to build component models. The keys should be model identifiers.
 *  @param identifierOrder An ordered array of identifiers of the models to build. This will determine the build order.
 *  @param parent Any parent of the component models to be built. Nil if an array of root component models are being built.
 *
 *  The `preferredIndex` property of each builder will also be taken into account, so the supplied `identifierOrder` is
 *  only used as a default order for the returned array of component models.
 */
+ (NSArray<id<HUBComponentModel>> *)buildComponentModelsUsingBuilders:(NSDictionary<NSString *, HUBComponentModelBuilderImplementation *> *)builders
                                                      identifierOrder:(NSArray<NSString *> *)identifierOrder
                                                               parent:(nullable id<HUBComponentModel>)parent;

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param modelIdentifier The identifier of the model to be built. If `nil`, an `NSUUID`-based identifier will be used.
 *  @param type The type of component that this builder is for
 *  @param JSONSchema The schema to use to parse data from any added JSON object
 *  @param componentDefaults The default component values that should be used as initial values for this builder
 *  @param iconImageResolver The resolver to use to convert icons into renderable images
 *  @param mainImageDataBuilder Any specific image data builder that the object should use for its main image.
 *  @param backgroundImageDataBuilder Any specific image data builder that the object should use for its background image.
 */
- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                                   type:(HUBComponentType)type
                             JSONSchema:(id<HUBJSONSchema>)JSONSchema
                      componentDefaults:(HUBComponentDefaults *)componentDefaults
                      iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                   mainImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)mainImageDataBuilder
             backgroundImageDataBuilder:(nullable HUBComponentImageDataBuilderImplementation *)backgroundImageDataBuilder HUB_DESIGNATED_INITIALIZER;

/**
 *  Build a component model instance from the data contained in this builder
 *
 *  @param index The index that the produced model will have, either within its parent or within the root list
 *  @param parent The parent of the component model to build. Nil if the model is for a root component.
 */
- (id<HUBComponentModel>)buildForIndex:(NSUInteger)index parent:(nullable id<HUBComponentModel>)parent;

@end

NS_ASSUME_NONNULL_END
