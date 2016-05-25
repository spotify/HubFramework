#import "___FILEBASENAME___.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize view = _view;

- (NSSet<HUBComponentLayoutTrait *> *)layoutTraits
{
    // Return a set of layout traits that describe your component's UI style
    return [NSSet new];
}

- (void)loadView
{
    // Create your view. You can give it a zero rectangle for its frame.
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    // Return the size you'd prefer that the layout system resizes your view to
    return CGSizeZero;
}

- (void)prepareViewForReuse
{
    // Prepare your view for reuse, reset state, remove highlights, etc.
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model
{
    // Do your model->view data binding here
}

- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    // Return the size you'd prefer an image to be, or CGSizeZero for non-supported types.
    switch (imageData.type) {
        case HUBComponentImageTypeMain:
        case HUBComponentImageTypeCustom:
        case HUBComponentImageTypeBackground:
            return CGSizeZero;
    }
}

- (void)updateViewForLoadedImage:(UIImage *)image fromData:(id<HUBComponentImageData>)imageData model:(id<HUBComponentModel>)model animated:(BOOL)animated
{
    // Update your view after an image was downloaded by the Hub Framework
}

@end

NS_ASSUME_NONNULL_END
