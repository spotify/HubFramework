#import "HUBComponentMock.h"

@implementation HUBComponentMock

@synthesize delegate = _delegate;

- (instancetype)createNewComponent
{
    return [HUBComponentMock new];
}

- (UIView *)loadView
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containedInViewWithSize:(CGSize)containerViewSize
{
    return CGSizeZero;
}

- (void)prepareViewForReuseWithModel:(id<HUBComponentModel>)model
{
    // No-op
}

- (void)updateViewForLoadedImage:(UIImage *)image forModel:(id<HUBComponentModel>)model
{
    // No-op
}

@end
