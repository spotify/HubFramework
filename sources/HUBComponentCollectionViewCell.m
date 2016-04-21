#import "HUBComponentCollectionViewCell.h"

#import "HUBComponentWrapper.h"
#import "HUBComponent.h"
#import "HUBUtilities.h"

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
    
    UIView * const view = HUBComponentLoadViewIfNeeded(componentWrapper.component);
    
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

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIView * const componentView = self.componentWrapper.component.view;
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        ((UICollectionViewCell *)componentView).selected = selected;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    UIView * const componentView = self.componentWrapper.component.view;
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        ((UICollectionViewCell *)componentView).highlighted = highlighted;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView * const componentView = self.componentWrapper.component.view;
    CGSize previousComponentViewSize = componentView.frame.size;
    
    componentView.bounds = self.contentView.bounds;
    componentView.center = self.contentView.center;
    
    if (!CGSizeEqualToSize(previousComponentViewSize, componentView.bounds.size)) {
        [self.componentWrapper.component updateViewAfterResize];
    }
}

@end

NS_ASSUME_NONNULL_END
