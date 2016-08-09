#import <UIKit/UIKit.h>

@protocol HUBViewController;
@protocol HUBViewModel;
@protocol HUBComponent;
@protocol HUBComponentModel;

/**
 * Enum defining scrolling behaviors of a `HUBViewController`.
 *
 * HUBViewControllerScrollModeDefault: no special behavior.
 * HUBViewControllerScrollModeVerticalPaging: the Hub view keeps one row centered in the view.
 */
typedef NS_ENUM(NSUInteger, HUBViewControllerScrollMode) {
    HUBViewControllerScrollModeDefault,
    HUBViewControllerScrollModeVerticalPaging,
};

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

/**
 *  Sent to a Hub Framework view controller's delegate when it failed to be updated because of an error
 *
 *  @param viewController The view controller that failed to update
 *  @param error The error that was encountered
 *
 *  You can use this method to perform any custom UI operations to visualize that an error occured. Any previously
 *  loaded view model will still be used even if an error was encountered.
 *
 *  Note that you can also use content operations (`HUBContentOperation`) to react to errors, and adjust the UI.
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController didFailToUpdateWithError:(NSError *)error;

/**
 *  Sent to a Hub Framework view controller's delegate when a component is about to appear on the screen
 *
 *  @param viewController The view controller in which a component is about to appear
 *  @param componentModel The model of the component that is about to appear
 *  @param componentView The view that the component is about to appear in
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
      willAppearInView:(UIView *)componentView;

/**
 *  Sent to a Hub Framework view controller's delegate when a component disappeared from the screen
 *
 *  @param viewController The view controller in which a component disappeared
 *  @param componentModel The model of the component that disappeared
 *  @param componentView The view that the component disappeared from
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
  didDisappearFromView:(UIView *)componentView;

/**
 *  Sent to a Hub Framework view controller's delegate when a component was selected
 *
 *  @param viewController The view controller in which the component was selected
 *  @param componentModel The model of the component that was selected
 *  @param componentView The view that the component was selected in
 */
- (void)viewController:(UIViewController<HUBViewController> *)viewController
    componentWithModel:(id<HUBComponentModel>)componentModel
        selectedInView:(UIView *)componentView;

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

/**
 * The scrolling mode of the view controller's view.
 *
 * The scrolling behavior is locked down once the view is created, so scrollMode should be set before the view
 * controller is added to a view hierarchy.
 */
@property (nonatomic) HUBViewControllerScrollMode scrollMode;

@end

NS_ASSUME_NONNULL_END
