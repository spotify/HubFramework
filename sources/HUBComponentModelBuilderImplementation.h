#import "HUBComponentModelBuilder.h"

@class HUBComponentModelImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentModelBuilder` API
@interface HUBComponentModelBuilderImplementation : NSObject <HUBComponentModelBuilder>

/**
 *  Initialize an instance of this class with its required data
 *
 *  @param modelIdentifier The identifier of the model that this builder is for
 *  @param componentIdentifier The identifier of the component that the model should be rendered using
 */
- (instancetype)initWithModelIdentifier:(NSString *)modelIdentifier
                    componentIdentifier:(NSString *)componentIdentifier NS_DESIGNATED_INITIALIZER;

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
