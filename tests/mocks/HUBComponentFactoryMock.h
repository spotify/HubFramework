#import "HUBComponentFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked component factory, for use in tests only
@interface HUBComponentFactoryMock : NSObject <HUBComponentFactory>

/// The view URIs that were passed to this component factory when creating new components for certain names
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSURL *> *viewURIsForComponentNames;

/// Initialize an instance of this class with a name:component dictionary of components to create
- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
