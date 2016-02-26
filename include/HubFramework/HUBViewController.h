#import <UIKit/UIKit.h>

@protocol HUBViewController;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol for `HUBViewController`
 *
 *  Conform to this protocol in a custom object to get notified of events occuring in a Hub Framework view controller
 */
@protocol HUBViewControllerDelegate <NSObject>

/**
 *  Sent to the delegate when the view controller either displayed or stopped displaying a header component
 *
 *  @param viewController The view controller in which the event occured
 *
 *  You can use this API to hide/show the application's navigation bar, or perform additional customization
 *  needed to display a header component in a good way. To check if a header component is currently being
 *  displayed, use the `isDisplayingHeaderComponent` property on the view controller.
 */
- (void)viewControllerHeaderComponentVisbilityDidChange:(UIViewController<HUBViewController> *)viewController;

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

/// Whether the view controller is currently displaying a header component or not
@property (nonatomic, readonly) BOOL isDisplayingHeaderComponent;

@end

NS_ASSUME_NONNULL_END
