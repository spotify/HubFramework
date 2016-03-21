#import "HUBDataLoaderFactory.h"

@class HUBDataLoaderMock;

NS_ASSUME_NONNULL_BEGIN

/// Mocked data loader factory, for use in tests only
@interface HUBDataLoaderFactoryMock : NSObject <HUBDataLoaderFactory>

/// The last data loader that the factory created
@property (nonatomic, strong, nullable, readonly) HUBDataLoaderMock *lastCreatedDataLoader;

@end

NS_ASSUME_NONNULL_END
