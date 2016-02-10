#import "HUBComponentCollectionViewCell.h"

#import "HUBComponent.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentCollectionViewCell

#pragma mark - Property overrides

- (void)setComponent:(nullable id<HUBComponent>)component
{
    if (component == _component) {
        return;
    }
    
    [_component.view removeFromSuperview];
    _component = component;
    
    if (component == nil) {
        return;
    }
    
    if (component.view == nil) {
        [component loadView];
    }
    
    [self.contentView addSubview:component.view];
}

#pragma mark - UICollectionViewCell

- (void)prepareForReuse
{
    [self.component prepareViewForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.component.view.frame = self.contentView.bounds;
}

@end

NS_ASSUME_NONNULL_END
