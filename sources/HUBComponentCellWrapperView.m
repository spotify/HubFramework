#import "HUBComponentCellWrapperView.h"

@implementation HUBComponentCellWrapperView

#pragma mark - Property overrides

- (void)setComponentView:(UIView *)componentView
{
    [_componentView removeFromSuperview];
    _componentView = componentView;
    [self addSubview:componentView];
}

#pragma mark - UIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

@end
