#import "HUBComponentCollectionViewCell.h"

#import "HUBComponent.h"
#import "HUBComponentViewObserver.h"
#import "HUBUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentCollectionViewCell

#pragma mark - Initializer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _identifier = [NSUUID UUID];
    }
    
    return self;
}

#pragma mark - Property overrides

- (void)setComponent:(nullable id<HUBComponent>)component
{
    if (_component == component) {
        return;
    }
    
    [_component.view removeFromSuperview];
    _component = component;
    
    if (component == nil) {
        return;
    }
    
    id<HUBComponent> const nonNilComponent = component;
    UIView * const componentView = HUBComponentLoadViewIfNeeded(nonNilComponent);
    
    if ([componentView isKindOfClass:[UICollectionViewCell class]]) {
        componentView.userInteractionEnabled = NO;
    }
    
    [self.contentView addSubview:componentView];
}

#pragma mark - UICollectionViewCell

- (void)prepareForReuse
{
    [self.component prepareViewForReuse];
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
