#import <Foundation/Foundation.h>

@protocol HUBActionContext;

/**
 *  Protocol used to define Hub Framework actions
 *
 *  Actions are independant pieces of code that can be executed in response to events, such as selection,
 *  other user interface events, timers, etc. They can be used to implement application-wide extensions
 *  to the Hub Framework and handle tasks like model mutations, user interface updates, etc. Actions are
 *  either performed automatically by the Hub Framework when a component was selected, or by a component
 *  conforming to the `HUBComponentActionPerformer` protocol.
 *
 *  Actions are created by an implementation of `HUBActionFactory`, which are registered for a certain
 *  namespace with `HUBActionRegistry`.
 */
@protocol HUBAction <NSObject>

/**
 *  Perform the action in a certain context
 *
 *  @param context The context to perform the action in
 *
 *  @return A boolean indicating whether the action was performed or not. When an action indicates success,
 *          it will stop any subsequent actions from being performed for the same event.
 */
- (BOOL)performWithContext:(id<HUBActionContext>)context;

@end
