#import "HUBViewControllerDefaultScrollHandler.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@implementation HUBViewControllerDefaultScrollHandler

- (BOOL)shouldShowScrollIndicatorsInViewController:(id<HUBViewController>)viewController
{
    return YES;
}

- (BOOL)shouldAutomaticallyAdjustContentInsetsInViewController:(id<HUBViewController>)viewController
{
    return YES;
}

- (CGFloat)scrollDecelerationRateForViewController:(id<HUBViewController>)viewController
{
    return UIScrollViewDecelerationRateNormal;
}

- (UIEdgeInsets)contentInsetsForViewController:(UIViewController<HUBViewController> *)viewController
                         proposedContentInsets:(UIEdgeInsets)proposedContentInsets
{
    return proposedContentInsets;
}

- (void)scrollingWillStartInViewController:(id<HUBViewController>)viewController
                        currentContentRect:(CGRect)currentContentRect
{
    // No-op
}

- (void)scrollingDidEndInViewController:(UIViewController<HUBViewController> *)viewController currentContentRect:(CGRect)currentContentRect
{
    // No-op
}

- (CGPoint)targetContentOffsetForEndedScrollInViewController:(UIViewController<HUBViewController> *)viewController
                                                    velocity:(CGVector)velocity
                                                contentInset:(UIEdgeInsets)contentInset
                                        currentContentOffset:(CGPoint)currentContentOffset
                                       proposedContentOffset:(CGPoint)proposedContentOffset
{
    return proposedContentOffset;
}

@end

NS_ASSUME_NONNULL_END
