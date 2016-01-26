#import "HUBViewModelBuilder.h"

@class HUBViewModelImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewModelBuilder` API
@interface HUBViewModelBuilderImplementation : NSObject <HUBViewModelBuilder>

/**
 *  Initialize an instance of this class with a feature identifier
 *
 *  @param featureIdentifier The identifier of the feature that this builder is for
 */
- (instancetype)initWithFeatureIdentifier:(NSString *)featureIdentifier NS_DESIGNATED_INITIALIZER;

/**
 *  Build an instance of `HUBViewModelImplementation` from the data contained in this builder
 */
- (HUBViewModelImplementation *)build;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
