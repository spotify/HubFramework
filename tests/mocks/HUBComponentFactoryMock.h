#import "HUBComponentFactoryShowcaseNameProvider.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked component factory, for use in tests only
@interface HUBComponentFactoryMock : NSObject <HUBComponentFactoryShowcaseNameProvider>

/// The components that this factory returns for a given name
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, id<HUBComponent>> *components;

/// The component names that the factory should declare as showcaseable
@property (nonatomic, strong, nullable) NSArray<NSString *> *showcaseableComponentNames;

/// A map between component names & human readable names that the factory should use to resolve showcasable names
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *showcaseNamesForComponentNames;

/// Initialize an instance of this class with a name:component dictionary of components to create
- (instancetype)initWithComponents:(NSDictionary<NSString *, id<HUBComponent>> *)components HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
