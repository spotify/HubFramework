#import "HUBIcon.h"
#import "HUBHeaderMacros.h"

@protocol HUBIconImageResolver;

NS_ASSUME_NONNULL_BEGIN

/// Concerete implementation of the `HUBIcon` protocol
@interface HUBIconImplementation : NSObject <HUBIcon>

/**
 *  Initialize an instance of this class with its required data
 *
 *  @param identifier The identifier of the icon
 *  @param imageResolver The resolver to use to convert the icon into a renderable image
 *  @param isPlaceholder Whether the icon is going to be used as a placeholder
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                     imageResolver:(id<HUBIconImageResolver>)imageResolver
                     isPlaceholder:(BOOL)isPlaceholder HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
