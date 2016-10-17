#import "HUBContentOperation.h"

@protocol HUBActionPerformer;

/**
 *  Extended content operation protocol that adds the ability to perform actions
 *
 *  Use this protocol whenever you want one of your content operations to be able to perform
 *  actions. Actions can be used to perform small, atomic tasks and provide a lightweight way
 *  to extend the Hub Framework with additional functionality.
 *
 *  For more information about actions, see `HUBAction`, as well as the "Action programming
 *  guide" available at https://spotify.github.io/HubFramework/action-programming-guide.html.
 *
 *  For more information about content operations, see `HUBContentOperation`.
 */
@protocol HUBContentOperationActionPerformer <HUBContentOperation>

/**
 *  An object that can be used to perform actions on behalf of this content operation
 *
 *  Don't assign any custom objects to this property. Instead, just \@sythensize it, so that
 *  the Hub Framework can assign an internal object to this property, to enable you to perform
 *  actions from the content operation.
 */
@property (nonatomic, weak, nullable) id<HUBActionPerformer> actionPerformer;

@end

