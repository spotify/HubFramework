#import <UIKit/UIKit.h>

@protocol HUBViewModel, HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol representing a context in which a selection occurred
 * 
 *  The Hub Framework will send an object conforming to this protocol to any
 *  `HUBComponentSelectionHandler` registered for the feature in which a
 *  selection occured.
 */
@protocol HUBComponentSelectionContext <NSObject>

/// The URI of the view which the selection event occured in.
@property (nonatomic, readonly) NSURL *viewURI;

/// The model of the view in which the selection event occured.
@property (nonatomic, readonly) id<HUBViewModel> viewModel;

/// The model of the component that was selected.
@property (nonatomic, readonly) id<HUBComponentModel> componentModel;

/// The view controller that the selection event occured in
@property (nonatomic, readonly) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END

