#import "HUBAutoEquatable.h"
#import "HUBComponentTarget.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBComponentTarget` API
@interface HUBComponentTargetImplementation : HUBAutoEquatable <HUBComponentTarget>

/**
 *  Initialize an instance of this class with its required data
 *
 *  @param URI The target's URI, opened upon user interactions
 *  @param initialViewModel The view model to inially use for any target view
 *  @param customData Custom data to associate with this target object
 */
- (instancetype)initWithURI:(nullable NSURL *)URI
           initialViewModel:(nullable id<HUBViewModel>)initialViewModel
                 customData:(nullable NSDictionary<NSString *, NSObject *> *)customData HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
