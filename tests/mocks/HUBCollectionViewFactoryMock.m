#import "HUBCollectionViewFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewFactoryMock ()

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

@implementation HUBCollectionViewFactoryMock

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    if (!(self = [super init])) {
        return nil;
    }
    
    _collectionView = collectionView;
    
    return self;
}

- (UICollectionView *)createCollectionView
{
    return self.collectionView;
}

@end

NS_ASSUME_NONNULL_END
