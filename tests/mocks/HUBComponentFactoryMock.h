#import "HUBComponentFactory.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked component factory, for use in tests only
@interface HUBComponentFactoryMock : NSObject <HUBComponentFactory>

/// Initialize an instance of this class with a name:component dictionary of components to create
- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
