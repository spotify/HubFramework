#import "HUBCollectionViewMock.h"
#import "HUBComponentCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewMock ()

@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *mutableSelectedIndexPaths;
@property (nonatomic, strong, readonly) NSMutableSet<NSIndexPath *> *mutableDeselectedIndexPaths;

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
    _mutableDeselectedIndexPaths = [NSMutableSet new];
    
    return self;
}

#pragma mark - Property overrides

- (NSSet<NSIndexPath *> *)selectedIndexPaths
{
    return [self.mutableSelectedIndexPaths copy];
}

- (NSSet<NSIndexPath *> *)deselectedIndexPaths
{
    return [self.mutableDeselectedIndexPaths copy];
}

- (NSArray<NSIndexPath *> *)indexPathsForVisibleItems
{
    NSArray<NSIndexPath *> * const mockedIndexPaths = self.mockedIndexPathsForVisibleItems;
    
    if (mockedIndexPaths != nil) {
        return mockedIndexPaths;
    }
    
    return [super indexPathsForVisibleItems];
}

#pragma mark - UICollectionView

- (UICollectionViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * const mockedCell = self.cells[indexPath];
    
    if (mockedCell != nil) {
        return mockedCell;
    }
    
    return [super dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

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
    [self.mutableDeselectedIndexPaths addObject:indexPath];
}

@end

NS_ASSUME_NONNULL_END
