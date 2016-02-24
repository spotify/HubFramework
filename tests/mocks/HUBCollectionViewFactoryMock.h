#import "HUBCollectionViewFactory.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked collection view factory, for use in tests only
@interface HUBCollectionViewFactoryMock : HUBCollectionViewFactory

/**
 *  Initialize an instance of this class with a collection view
 *
 *  @param collectionView A collection view that this factory will always create
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
