#import <UIKit/UIKit.h>

@protocol HUBViewModel, HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * Protocol representing a context in which a selection occurred.
 * 
 * Contains the models for both the view and the component
 * which was selected, as well as the view controller used to present
 * them both.
 */
@protocol HUBComponentSelectionContext <NSObject>

/// The URI of the view which the selection event occured in.
@property (nonatomic, readonly) NSURL *viewURI;

/// The model of the view which the selection event occured in.
@property (nonatomic, readonly) id<HUBViewModel> viewModel;

/// The model of the component which was selected.
@property (nonatomic, readonly) id<HUBComponentModel> componentModel;

/// The view controller that the selection event occured in
@property (nonatomic, readonly) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END

