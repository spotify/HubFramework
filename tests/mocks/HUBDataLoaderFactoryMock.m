#import "HUBDataLoaderFactoryMock.h"

#import "HUBDataLoaderMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBDataLoaderFactoryMock ()

@property (nonatomic, strong, nullable, readwrite) HUBDataLoaderMock *lastCreatedDataLoader;

@end

@implementation HUBDataLoaderFactoryMock

- (id<HUBDataLoader>)createDataLoaderForFeatureWithIdentifier:(NSString *)featureIdentifier
{
    HUBDataLoaderMock * const dataLoader = [[HUBDataLoaderMock alloc] initWithFeatureIdentifier:featureIdentifier];
    self.lastCreatedDataLoader = dataLoader;
    return dataLoader;
}

@end

NS_ASSUME_NONNULL_END
