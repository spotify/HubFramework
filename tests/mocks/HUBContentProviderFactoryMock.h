#import "HUBContentProviderFactory.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked content provider factory, for use in tests only
@interface HUBContentProviderFactoryMock : NSObject <HUBContentProviderFactory>

/**
 *  Initialize an instance of this class with an array of content providers
 *
 *  @param contentProviders The content providers that this factory is always returning
 */
- (instancetype)initWithContentProviders:(NSArray<id<HUBContentProvider>> *)contentProviders NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
