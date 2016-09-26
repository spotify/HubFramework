#import <UIKit/UIKit.h>

@protocol HUBActionContext;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol used to define Hub Framework action handlers
 *
 *  An action handler is an object that optionally takes over the handling of an action,
 *  preventing that action from executing as it normally would. This enables you to customize
 *  what will happen for certain actions, including selection and other events.
 *
 *  Each feature can supply each own action handler when it's being setup with `HUBFeatureRegistry`.
 *  A default action handler to be used system-wide can also be supplied when setting up this
 *  application's `HUBManager`.
 */
@protocol HUBActionHandler <NSObject>

/**
 *  Handle an action with a given context
 *
 *  @param context The context of the action to handle
 *
 *  @return A boolean indicating whether the action was handled. If `YES` is returned, the action
 *          will be considered handled, and it won't be executed.
 */
- (BOOL)handleActionWithContext:(id<HUBActionContext>)context;

@end

NS_ASSUME_NONNULL_END
