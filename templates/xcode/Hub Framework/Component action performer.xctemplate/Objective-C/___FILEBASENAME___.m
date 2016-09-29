#import "___FILEBASENAME___.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ___FILEBASENAMEASIDENTIFIER___

@synthesize view = _view;
@synthesize actionDelegate = _actionDelegate;

- (NSSet<HUBComponentLayoutTrait> *)layoutTraits
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

- (void)configureViewWithModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    // Do your model->view data binding here
}

@end

NS_ASSUME_NONNULL_END
