#import "HUBContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBContainerView

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    for (UIView * const view in self.subviews) {
        view.backgroundColor = backgroundColor;
    }
}

- (void)didAddSubview:(UIView *)subview
{
    subview.backgroundColor = self.backgroundColor;
}

@end

NS_ASSUME_NONNULL_END
