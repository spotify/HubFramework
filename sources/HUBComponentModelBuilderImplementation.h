#import "HUBComponentModelBuilder.h"
#import "HUBJSONCompatibleBuilder.h"

@protocol HUBJSONSchema;
@class HUBComponentModelImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentModelBuilder` API
@interface HUBComponentModelBuilderImplementation : NSObject <HUBComponentModelBuilder, HUBJSONCompatibleBuilder>

/**
 *  Build an array of component models from a collection of builders
 *
 *  @param builders The builders to use to build component models. The keys should be model identifiers.
 *  @param identifierOrder An ordered array of identifiers of the models to build. This will determine the build order.
 *
 *  The `preferredIndex` property of each builder will also be taken into account, so the supplied `identifierOrder` is
 *  only used as a default order for the returned array of component models.
 */
+ (NSArray<HUBComponentModelImplementation *> *)buildComponentModelsUsingBuilders:(NSDictionary<NSString *, HUBComponentModelBuilderImplementation *> *)builders
                                                                  identifierOrder:(NSArray<NSString *> *)identifierOrder;

/**
 *  Initialize an instance of this class with a component model identifier
 *
 *  @param modelIdentifier The identifier of the model to be built. If `nil`, an `NSUUID`-based identifier will be used.
 *  @param featureIdentifier The identifier of the feature that the component will be presented in
 */
- (instancetype)initWithModelIdentifier:(nullable NSString *)modelIdentifier
                      featureIdentifier:(NSString *)featureIdentifier NS_DESIGNATED_INITIALIZER;

/**
 *  Build an instance of `HUBComponentModelImplementation` from the data contained in this builder
 */
- (HUBComponentModelImplementation *)build;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
