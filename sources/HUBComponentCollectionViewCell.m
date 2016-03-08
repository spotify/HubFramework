#import "HUBComponentCollectionViewCell.h"

#import "HUBComponentWrapper.h"
#import "HUBComponent.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentCollectionViewCell

#pragma mark - Property overrides

- (void)setComponentWrapper:(nullable HUBComponentWrapper *)componentWrapper
{
    if (_componentWrapper == componentWrapper) {
        return;
    }
    
    [_componentWrapper.component.view removeFromSuperview];
    _componentWrapper = componentWrapper;
    
    if (componentWrapper == nil) {
        return;
    }
    
    if (componentWrapper.component.view == nil) {
        [componentWrapper.component loadView];
    }
    
    UIView * const view = componentWrapper.component.view;
    NSAssert(view, @"All components are required to load a view in -loadView");
    
    if ([view isKindOfClass:[UICollectionViewCell class]]) {
        view.userInteractionEnabled = NO;
    }
    
    [self.contentView addSubview:view];
}

#pragma mark - UICollectionViewCell

- (void)prepareForReuse
{
    [self.componentWrapper.component prepareViewForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView * const componentView = self.componentWrapper.component.view;
    componentView.bounds = self.contentView.bounds;
    componentView.center = self.contentView.center;
}

@end

NS_ASSUME_NONNULL_END
