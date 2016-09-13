#import "HUBContentOperation.h"

@protocol HUBAction;
@protocol HUBActionContext;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended content operation protocol that adds the ability to observe whenever an action was performed
 *
 *  You can use this protocol to be able to react to an action being performed in your content operation.
 *
 *  See `HUBContentOperation` and `HUBAction` for more information.
 */
@protocol HUBContentOperationActionObserver <HUBContentOperation>

/**
 *  Sent to a content operation whenever an action was performed in the view that it is being used in
 *
 *  @param context The contextual object that the action was performed with
 *  @param viewURI The URI of the view that the action was performed in
 *  @param featureInfo The information for the feature that the action was performed in
 *  @param connectivityState The current connectivity state of the application
 *
 *  The Hub Framework will call this method on your content operation every time that an action was performed
 *  in the view that it is being used in, including both default selection actions & custom ones. You can
 *  use this method to mutate a content operation's state, and then reschedule it to be able to manipulate the
 *  content that is being displayed in the view.
 */
- (void)actionPerformedWithContext:(id<HUBActionContext>)context
                           viewURI:(NSURL *)viewURI
                       featureInfo:(id<HUBFeatureInfo>)featureInfo
                 connectivityState:(HUBConnectivityState)connectivityState;

@end

NS_ASSUME_NONNULL_END

