#import <UIKit/UIKit.h>

@protocol HUBViewModel, HUBComponentModel;
@class HUBIdentifier;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a contextual object used when executing an action
 *
 *  The Hub Framework automatically creates objects conforming to this protocol as part of
 *  handling an event which should cause an action to be performed. The context includes
 *  information that an action can use to make decisions on how to execute, and is always
 *  relative to the component for which the action will be performed.
 */
@protocol HUBActionContext <NSObject>

/// The identifier of the action that is being performed
@property (nonatomic, strong, readonly) HUBIdentifier *actionIdentifier;

/// The URI of the view that the action is being performed in
@property (nonatomic, copy, readonly) NSURL *viewURI;

/// The view model of the view that the action is being performed in
@property (nonatomic, strong, readonly) id<HUBViewModel> viewModel;

/// The model of the component that the action is being performed for
@property (nonatomic, strong, readonly) id<HUBComponentModel> componentModel;

/// The view controller that the action is being performed in
@property (nonatomic, strong, readonly) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END

