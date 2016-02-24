#import "HUBCollectionViewFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBCollectionViewFactory

- (UICollectionView *)createCollectionView
{
    return [[UICollectionView alloc] initWithFrame:CGRectZero
                              collectionViewLayout:[UICollectionViewFlowLayout new]];
}

@end

NS_ASSUME_NONNULL_END
