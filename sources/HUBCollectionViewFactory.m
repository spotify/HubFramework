#import "HUBCollectionViewFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBCollectionViewFactory

- (UICollectionView *)createCollectionView
{
    return [[UICollectionView alloc] initWithFrame:CGRectZero
                              collectionViewLayout:[UICollectionViewLayout new]];
}

@end

NS_ASSUME_NONNULL_END
