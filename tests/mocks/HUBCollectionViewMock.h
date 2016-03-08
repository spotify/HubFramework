#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Mocked collection view, for use in tests only
@interface HUBCollectionViewMock : UICollectionView

/// The cells that the collection view will consider as being part of it
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, UICollectionViewCell *> *cells;

/// The index paths that are currently considered selected in the collection view
@property (nonatomic, strong, readonly) NSSet<NSIndexPath *> *selectedIndexPaths;

@end

NS_ASSUME_NONNULL_END
