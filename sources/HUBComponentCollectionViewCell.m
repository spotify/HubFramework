#import "HUBComponentCollectionViewCell.h"

#import "HUBComponentWrapper.h"
#import "HUBComponent.h"
#import "HUBComponentViewObserver.h"
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
    
    HUBComponentWrapper * const nonNilComponentWrapper = componentWrapper;
    UIView * const view = HUBComponentLoadViewIfNeeded(nonNilComponentWrapper.component);
    
    if ([view isKindOfClass:[UICollectionViewCell class]]) {
        view.userInteractionEnabled = NO;
    }
    
    [self.contentView addSubview:view];
}

#pragma mark - UICollectionViewCell

- (void)prepareForReuse
{
    [self.componentWrapper saveComponentUIState];
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
    
    id<HUBComponent> const component = self.componentWrapper.component;
    UIView * const componentView = component.view;
    CGSize previousComponentViewSize = componentView.frame.size;
    
    componentView.bounds = self.contentView.bounds;
    componentView.center = self.contentView.center;
    
    if (!CGSizeEqualToSize(previousComponentViewSize, componentView.bounds.size)) {
        if ([component conformsToProtocol:@protocol(HUBComponentViewObserver)]) {
            [(id<HUBComponentViewObserver>)component viewDidResize];
        }
    }
}

@end

NS_ASSUME_NONNULL_END
