#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Mocked collection view, for use in tests only
@interface HUBCollectionViewMock : UICollectionView

/// The cells that the collection view will consider as being part of it
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, UICollectionViewCell *> *cells;

/// The index paths that have been selected in the collection view
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *selectedIndexPaths;

/// The index paths that have been deselected in the collection view
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *deselectedIndexPaths;

/// The index paths of the items that the collection view should act like it's displaying
@property (nonatomic, strong, nullable) NSArray<NSIndexPath *> *mockedIndexPathsForVisibleItems;

/// Any cells that the collection view should act like it's displaying
@property (nonatomic, strong, nullable) NSArray<UICollectionViewCell *> *mockedVisibleCells;

/// The offset that has been scrolled to
@property (nonatomic) CGPoint appliedScrollViewOffset;

/// The animated flag applied when offet is scrolled to.
@property (nonatomic) BOOL appliedScrollViewOffsetAnimatedFlag;

@end

NS_ASSUME_NONNULL_END
