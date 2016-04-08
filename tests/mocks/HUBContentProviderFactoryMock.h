#import "HUBContentProviderFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content provider factory, for use in tests only
@interface HUBContentProviderFactoryMock : NSObject <HUBContentProviderFactory>

/**
 *  Initialize an instance of this class with an array of content providers
 *
 *  @param contentProviders The content providers that this factory is always returning
 */
- (instancetype)initWithContentProviders:(NSArray<id<HUBContentProvider>> *)contentProviders HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
