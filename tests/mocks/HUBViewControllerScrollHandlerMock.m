#import "HUBViewControllerScrollHandlerMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBViewControllerScrollHandlerMock ()

@property (nonatomic, assign, readwrite) UIEdgeInsets proposedContentInsets;
@property (nonatomic, assign, readwrite) CGRect startContentRect;

@end

@implementation HUBViewControllerScrollHandlerMock

- (BOOL)shouldShowScrollIndicatorsInViewController:(UIViewController<HUBViewController> *)viewController
{
    return self.shouldShowScrollIndicators;
}

- (BOOL)shouldAutomaticallyAdjustContentInsetsInViewController:(UIViewController<HUBViewController> *)viewController
{
    return self.shouldAutomaticallyAdjustContentInsets;
}

- (CGFloat)scrollDecelerationRateForViewController:(UIViewController<HUBViewController> *)viewController
{
    return self.scrollDecelerationRate;
}

- (UIEdgeInsets)contentInsetsForViewController:(UIViewController<HUBViewController> *)viewController
                         proposedContentInsets:(UIEdgeInsets)proposedContentInsets
{
    return self.contentInsets;
}

- (void)scrollingWillStartInViewController:(UIViewController<HUBViewController> *)viewController
                        currentContentRect:(CGRect)currentContentRect
{
    self.startContentRect = currentContentRect;
}

- (CGPoint)targetContentOffsetForEndedScrollInViewController:(UIViewController<HUBViewController> *)viewController
                                                    velocity:(CGVector)velocity
                                                contentInset:(UIEdgeInsets)contentInset
                                        currentContentOffset:(CGPoint)currentContentOffset
                                       proposedContentOffset:(CGPoint)proposedContentOffset
{
    return self.targetContentOffset;
}

@end

NS_ASSUME_NONNULL_END
