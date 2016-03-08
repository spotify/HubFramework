#import "HUBCollectionViewMock.h"
#import "HUBComponentCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewMock ()

@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *mutableSelectedIndexPaths;

@end

@implementation HUBCollectionViewMock

- (instancetype)init
{
    UICollectionViewLayout * const layout = [UICollectionViewFlowLayout new];
    
    if (!(self = [super initWithFrame:CGRectZero collectionViewLayout:layout])) {
        return nil;
    }
    
    _cells = [NSMutableDictionary new];
    _mutableSelectedIndexPaths = [NSMutableSet new];
    
    return self;
}

#pragma mark - Property overrides

- (NSSet<NSIndexPath *> *)selectedIndexPaths
{
    return [self.mutableSelectedIndexPaths copy];
}

#pragma mark - UICollectionView

- (nullable UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cells[indexPath];
}

- (void)selectItemAtIndexPath:(nullable NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UICollectionViewScrollPosition)scrollPosition
{
    [super selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    
    if (indexPath != nil) {
        NSIndexPath * const nonNilIndexPath = indexPath;
        [self.mutableSelectedIndexPaths addObject:nonNilIndexPath];
    }
}

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [super deselectItemAtIndexPath:indexPath animated:animated];
    [self.mutableSelectedIndexPaths removeObject:indexPath];
}

@end

NS_ASSUME_NONNULL_END
