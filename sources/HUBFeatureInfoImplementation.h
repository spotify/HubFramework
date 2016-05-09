#import "HUBFeatureInfo.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBFeatureInfo` protocol
@interface HUBFeatureInfoImplementation : NSObject <HUBFeatureInfo>

/**
 *  Initialize an instance of this class with an identifier and a title
 *
 *  @param identifier The identifier of the feature that this info object is for
 *  @param title The localized title of the feature that this info object is for
 */
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
