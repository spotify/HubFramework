#import "HUBComponentReusePool.h"

@protocol HUBComponentWrapper;

NS_ASSUME_NONNULL_BEGIN

/// Mocked component reuse pool, for use in unit tests only
@interface HUBComponentReusePoolMock : HUBComponentReusePool

/// The components that are currently in use. The mock keeps a weak reference to these components.
@property (nonatomic, strong, readonly) NSArray<HUBComponentWrapper *> *componentsInUse;

@end

NS_ASSUME_NONNULL_END
