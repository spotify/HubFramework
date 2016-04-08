#import "HUBCollectionViewFactory.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Mocked collection view factory, for use in tests only
@interface HUBCollectionViewFactoryMock : HUBCollectionViewFactory

/**
 *  Initialize an instance of this class with a collection view
 *
 *  @param collectionView A collection view that this factory will always create
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
