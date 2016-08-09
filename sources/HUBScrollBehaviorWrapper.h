#import "HUBScrollBehavior.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A HUBScrollBehaviorWrapper implements all methods of HUBScrollBehavior, and forwards them to an underlying
 * HUBScrollBehavior if it implements them, otherwise provides default behavior.
 */
@interface HUBScrollBehaviorWrapper : NSObject <HUBScrollBehavior>

/**
 * Initialize a HUBScrollBehaviorWrapper that wraps a given underlying behavior.
 */
- (instancetype)initWithUnderlyingBehavior:(nullable id<HUBScrollBehavior>)underlyingBehavior
    HUB_DESIGNATED_INITIALIZER;

/// @see HUBScrollBehavior
- (BOOL)collectionViewShouldAdjustContentOffsetForStatusBarOnly:(UICollectionView *)collectionView;

/// @see HUBScrollBehavior
- (void)collectionViewWillBeginDragging:(UICollectionView *)collectionView;

/// @see HUBScrollBehavior
- (void)collectionViewWillEndDragging:(UICollectionView *)collectionView
                         withVelocity:(CGPoint)velocity
                  targetContentOffset:(inout CGPoint *)targetContentOffset;

/// @see HUBScrollBehavior
- (void)adjustMargins:(UIEdgeInsets *)margins
         forComponent:(id<HUBComponent>)component
        componentSize:(CGSize)componentSize
   collectionViewSize:(CGSize)collectionViewSize
           isInTopRow:(BOOL)isInTopRow
      isLastComponent:(BOOL)isLastComponent;

@end

NS_ASSUME_NONNULL_END
