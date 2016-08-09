#import "HUBScrollBehaviorWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBScrollBehaviorWrapper ()

@property (nonatomic, strong, nullable) id<HUBScrollBehavior> underlyingBehavior;

@end

@implementation HUBScrollBehaviorWrapper

- (instancetype)initWithUnderlyingBehavior:(nullable id<HUBScrollBehavior>)underlyingBehavior
{
    self = [super init];
    if (self != nil) {
        _underlyingBehavior = underlyingBehavior;
    }
    return self;
}

- (void)configureCollectionView:(UICollectionView *)collectionView viewController:(UIViewController *)viewController
{
    [self.underlyingBehavior configureCollectionView:collectionView viewController:viewController];
}

- (BOOL)collectionViewShouldAdjustContentOffsetForStatusBarOnly:(UICollectionView *)collectionView
{
    if ([self.underlyingBehavior respondsToSelector:@selector(collectionViewShouldAdjustContentOffsetForStatusBarOnly:)]) {
        return [self.underlyingBehavior collectionViewShouldAdjustContentOffsetForStatusBarOnly:collectionView];
    } else {
        return YES;
    }
}

- (void)collectionViewWillBeginDragging:(UICollectionView *)collectionView
{
    if ([self.underlyingBehavior respondsToSelector:@selector(collectionViewWillBeginDragging:)]) {
        [self.underlyingBehavior collectionViewWillBeginDragging:collectionView];
    }
}

- (void)collectionViewWillEndDragging:(UICollectionView *)collectionView
                         withVelocity:(CGPoint)velocity
                  targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.underlyingBehavior respondsToSelector:@selector(collectionViewWillEndDragging:
                                                              withVelocity:
                                                              targetContentOffset:)]) {
        [self.underlyingBehavior collectionViewWillEndDragging:collectionView
                                                  withVelocity:velocity
                                           targetContentOffset:targetContentOffset];
    }
}

- (void)adjustMargins:(UIEdgeInsets *)margins
         forComponent:(id<HUBComponent>)component
        componentSize:(CGSize)componentSize
   collectionViewSize:(CGSize)collectionViewSize
           isInTopRow:(BOOL)isInTopRow
      isLastComponent:(BOOL)isLastComponent
{
    if ([self.underlyingBehavior respondsToSelector:@selector(adjustMargins:
                                                              forComponent:
                                                              componentSize:
                                                              collectionViewSize:
                                                              isInTopRow:
                                                              isLastComponent:)]) {
        [self.underlyingBehavior adjustMargins:margins
                                  forComponent:component
                                 componentSize:componentSize
                            collectionViewSize:collectionViewSize
                                    isInTopRow:isInTopRow
                               isLastComponent:isLastComponent];
    }
}

@end

NS_ASSUME_NONNULL_END
