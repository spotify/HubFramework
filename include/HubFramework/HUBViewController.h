#import <UIKit/UIKit.h>

@protocol HUBViewController;
@protocol HUBViewModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBViewController`
 *
 *  Conform to this protocol in a custom object to get notified of events occuring in a Hub Framework view controller
 */
@protocol HUBViewControllerDelegate <NSObject>

/**
 *  Sent to a Hub Framework view controller's delegate when it was updated with a new view model
 *
 *  @param viewController The view controller that was updated
 *  @param viewModel The view model that the view controller was updated with
 *
 *  You can use this method to perform any custom UI operations on the whole view controller after a new view model
 *  was constructed and started to being used.
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController didUpdateWithViewModel:(id<HUBViewModel>)viewModel;

@end

/**
 *  Protocol defining the public API of a Hub Framework view controller
 *
 *  You don't conform to this protocol yourself, instead the Hub Framework will create view controllers conforming
 *  to this protocol through `HUBViewControllerFactory`.
 */
@protocol HUBViewController <NSObject>

/// The view controller's delegate. See `HUBViewControllerDelegate` for more information.
@property (nonatomic, weak, nullable) id<HUBViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
