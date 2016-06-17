#import "HUBConnectivityState.h"

@protocol HUBConnectivityStateResolver;

NS_ASSUME_NONNULL_BEGIN

/// Protocol used to observe a connectivity state resolver for changes in connectivity state
@protocol HUBConnectivityStateResolverObserver <NSObject>

/**
 *  Notifiy an observer that the application's connectivity state changed
 *
 *  @param resolver The resolver that detected the change
 *
 *  A connectivity state resolver should send this to all of its observers once it detected
 *  a change in connectivity state. The Hub Framework will react to this, and reschedule a
 *  reload of any visible view's content.
 */
- (void)connectivityStateResolverStateDidChange:(id<HUBConnectivityStateResolver>)resolver;

@end

/**
 *  Protocol implemented by objects that can resolve an application's current connectivity state
 *
 *  You conform to this protocol in a custom object and supply it when setting up your application's
 *  `HUBManager`. The Hub Framework passes the information provided by its connectivity state resolver
 *  to content operations when they are performed, enabling them to make decisions on whether to attempt
 *  to load remote content or not.
 *
 *  The resolver should also support observations; to enable the Hub Framework to react to changes
 *  in connectivity state. Whenever the resolver detected a change, it should call its observers.
 */
@protocol HUBConnectivityStateResolver <NSObject>

/**
 *  Resolve the current connectivity state of the application
 *
 *  The Hub Framework will call this method on your connectivity state resolver every time it's about
 *  to load content. It will be called once per content loading chain, ensuring connectivity state
 *  consistency within the chain.
 */
- (HUBConnectivityState)resolveConnectivityState;

/**
 *  Add an observer to the connectivity state resolver
 *
 *  @param observer The observer to add
 *
 *  The connectivity state resolver should not retain the observer. Instead, it should just keep a weak
 *  reference to it, and call it whenever the connectivity state was changed.
 */
- (void)addObserver:(id<HUBConnectivityStateResolverObserver>)observer;

/**
 *  Remove an observer from the connectivity state resolver
 *
 *  @param observer The observer to remove
 *
 *  The connectivity state resolver should immediately remove the observer.
 */
- (void)removeObserver:(id<HUBConnectivityStateResolverObserver>)observer;

@end

NS_ASSUME_NONNULL_END
