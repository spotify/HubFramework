#import "HUBIconImageResolver.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked icon image resolver, for use in tests only
@interface HUBIconImageResolverMock : NSObject <HUBIconImageResolver>

/// The icon to return for component icon requests
@property (nonatomic, strong, nullable) UIImage *imageForComponentIcons;

/// The icon to return for placeholder icon requests
@property (nonatomic, strong, nullable) UIImage *imageForPlaceholderIcons;

@end

NS_ASSUME_NONNULL_END
