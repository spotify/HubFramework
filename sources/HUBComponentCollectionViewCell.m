#import "HUBComponentCollectionViewCell.h"

#import "HUBComponentWrapper.h"
#import "HUBComponent.h"
#import "HUBComponentViewObserver.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentCollectionViewCell

#pragma mark - Property overrides

- (void)setComponent:(nullable id<HUBComponentWrapper>)component
{
    if (_component == component) {
        return;
    }
    
    [_component.view removeFromSuperview];
    _component = component;
    
    if (component == nil) {
        return;
    }
    
    id<HUBComponentWrapper> const nonNilComponent = component;
    
    if ([nonNilComponent.view isKindOfClass:[UICollectionViewCell class]]) {
        nonNilComponent.view.userInteractionEnabled = NO;
    }
    
    [self.contentView addSubview:nonNilComponent.view];
}

#pragma mark - UICollectionViewCell

- (void)prepareForReuse
{
    [self.component prepareForReuse];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIView * const componentView = self.component.view;
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        ((UICollectionViewCell *)componentView).selected = selected;
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    UIView * const componentView = self.component.view;
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        ((UICollectionViewCell *)componentView).highlighted = highlighted;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView * const componentView = self.component.view;
    componentView.bounds = self.contentView.bounds;
    componentView.center = self.contentView.center;
}

@end

NS_ASSUME_NONNULL_END
