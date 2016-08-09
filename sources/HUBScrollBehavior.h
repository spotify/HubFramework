#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HUBComponent;
@protocol HUBComponentModel;

/**
 * Protocol for an object that modifies the scrolling behavior of a `HUBViewControllerImplementation`. This is used to
 * implement the `HUBViewControllerScrollMode`s.
 */
@protocol HUBScrollBehavior <NSObject>

/**
 * Called when the scroll behavior is associated with a particular view and view controller.
 */
- (void)configureCollectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController;

@optional

/**
 * Determines whether the view controller should add a content inset if the presenting view controller has no navigation
 * bar. Default: YES.
 */
- (BOOL)collectionViewShouldAdjustContentOffsetForStatusBarOnly:(UICollectionView *)collectionView;

/**
 * Called on start of dragging (may require some time and or distance to move).
 *
 * Equivalent to `UIScrollViewDelegate`'s `scrollViewWillBeginDragging:`.
 */
- (void)collectionViewWillBeginDragging:(UICollectionView *)collectionView;

/**
 * Called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to
 * adjust where the scroll view comes to rest.
 *
 * Equivalent to `UIScrollViewDelegate`'s `scrollViewWillEndDragging:withVelocity:targetContentOffset:`.
 */
- (void)collectionViewWillEndDragging:(UICollectionView *)collectionView
                         withVelocity:(CGPoint)velocity
                  targetContentOffset:(inout CGPoint *)targetContentOffset;

/**
 * Called for each component in the collection view during layout. The scroll behavior may change the margins before
 * they are applied.
 */
- (void)adjustMargins:(UIEdgeInsets *)margins
         forComponent:(id<HUBComponent>)component
        componentSize:(CGSize)componentSize
   collectionViewSize:(CGSize)collectionViewSize
           isInTopRow:(BOOL)isInTopRow
      isLastComponent:(BOOL)isLastComponent;

@end

NS_ASSUME_NONNULL_END
