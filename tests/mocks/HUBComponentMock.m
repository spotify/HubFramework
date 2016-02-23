#import "HUBComponentMock.h"

@implementation HUBComponentMock

@synthesize delegate = _delegate;
@synthesize view = _view;

- (instancetype)createNewComponent
{
    return [HUBComponentMock new];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)prepareViewForReuse
{
    // No-op
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return CGSizeZero;
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model
{
    // No-op
}

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    return CGSizeMake(100, 100);
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    // No-op
}

@end
