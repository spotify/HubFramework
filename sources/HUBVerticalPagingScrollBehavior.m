#import "HUBVerticalPagingScrollBehavior.h"
#import <tgmath.h>

@interface HUBVerticalPagingScrollBehavior ()

@property (nonatomic, strong) NSIndexPath *ongoingScrollStartIndexPath;

@end

static const CGFloat HUBVerticalPagingDeltaSnappingThreshold = (CGFloat)0.3;
static const CGFloat HUBVerticalPagingVelocitySnappingThreshold = (CGFloat)0.5;

@implementation HUBVerticalPagingScrollBehavior

- (void)configureCollectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController
{
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    viewController.automaticallyAdjustsScrollViewInsets = NO;
}

- (BOOL)collectionViewShouldAdjustContentOffsetForStatusBarOnly:(UICollectionView *)collectionView
{
    return NO;
}

- (void)collectionViewWillBeginDragging:(UICollectionView *)collectionView
{
    CGFloat centerX = CGRectGetMidX(collectionView.bounds);
    CGFloat centerY = CGRectGetMidY(collectionView.bounds);

    self.ongoingScrollStartIndexPath = [collectionView indexPathForItemAtPoint:CGPointMake(centerX, centerY)];
}

- (void)collectionViewWillEndDragging:(UICollectionView *)collectionView
                         withVelocity:(CGPoint)velocity
                  targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint currentOffset = collectionView.contentOffset;

    NSIndexPath *startIndexPath = self.ongoingScrollStartIndexPath;
    NSIndexPath *targetIndexPath = startIndexPath;

    UICollectionViewLayoutAttributes *startAttributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:startIndexPath];
    CGPoint previousOffset = CGPointMake(
        startAttributes.center.x - CGRectGetWidth(collectionView.frame) / (CGFloat)2.0,
        startAttributes.center.y - CGRectGetHeight(collectionView.frame) / (CGFloat)2.0
    );

    CGFloat relativeDelta = (currentOffset.y - previousOffset.y) / CGRectGetHeight(collectionView.frame);
    CGFloat directionalVelocity = velocity.y;

    NSInteger numberOfItems = [collectionView numberOfItemsInSection:startIndexPath.section];
    // Offset is outside bounds, bounce back to where scrolling started
    if (currentOffset.y < 0.0) {
        targetIndexPath = startIndexPath;
    // Scrolling is done in a forward direction, snap to the next item
    } else if (relativeDelta >= HUBVerticalPagingDeltaSnappingThreshold || directionalVelocity > HUBVerticalPagingVelocitySnappingThreshold) {
        if ((startIndexPath.item + 1) < numberOfItems) {
            targetIndexPath = [NSIndexPath indexPathForItem:startIndexPath.item + 1 inSection:startIndexPath.section];
        }
    // Scrolling is done in a backward direction, snap to the previous item
    } else if (relativeDelta <= -HUBVerticalPagingDeltaSnappingThreshold || directionalVelocity < -HUBVerticalPagingVelocitySnappingThreshold) {
        if (startIndexPath.item > 0) {
            targetIndexPath = [NSIndexPath indexPathForItem:startIndexPath.item - 1 inSection:startIndexPath.section];
        }
    }

    self.ongoingScrollStartIndexPath = nil;
    *targetContentOffset = [self contentOffsetForCenteringItemAtIndexPath:targetIndexPath
                                                         inCollectionView:collectionView];
}

- (CGPoint)contentOffsetForCenteringItemAtIndexPath:(NSIndexPath *)indexPath
                                   inCollectionView:(UICollectionView *)collectionView
{
    UICollectionViewLayoutAttributes *attributes = [collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];

    const CGFloat center = CGRectGetHeight(collectionView.frame) / (CGFloat)2.0;
    const CGFloat offset = (CGFloat)floor(attributes.center.y - center);
    const CGPoint targetOffset = CGPointMake(collectionView.contentOffset.x, offset);
    return targetOffset;
}

- (void)adjustMargins:(UIEdgeInsets *)margins
         forComponent:(id<HUBComponent>)component
        componentSize:(CGSize)componentSize
   collectionViewSize:(CGSize)collectionViewSize
           isInTopRow:(BOOL)isInTopRow
      isLastComponent:(BOOL)isLastComponent
{
    if (isInTopRow) {
        margins->top = (collectionViewSize.height - componentSize.height) / (CGFloat)2.0;
    } else if (isLastComponent) {
        margins->bottom = (collectionViewSize.height - componentSize.height) / (CGFloat)2.0;
    }
}

@end
