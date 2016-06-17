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

- (void)viewDidResize
{
    // Update the component after it was resized by the layout system
}

- (void)viewWillAppear
{
    // Called when the component is about to appear on the screen
}

@end

NS_ASSUME_NONNULL_END
