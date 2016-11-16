#import "HUBHeaderMacros.h"

@class HUBAsyncActionWrapper;
@class HUBIdentifier;
@protocol HUBAsyncAction;
@protocol HUBActionContext;

NS_ASSUME_NONNULL_BEGIN

/// Delegate protocol for `HUBAsyncActionWrapper`
@protocol HUBAsyncActionWrapperDelegate <NSObject>

/**
 *  Notify an async action wrapper's delegate that it finished
 *
 *  @param action The action that finished
 *  @param context The context that the action was performed using
 *  @param nextActionIdentifier The identifier of any chained action to perform
 *  @param nextActionCustomData Any custom data to pass to the chained action
 */
- (void)actionDidFinish:(HUBAsyncActionWrapper *)action
        withContext:(id<HUBActionContext>)context
        chainToActionWithIdentifier:(nullable HUBIdentifier *)nextActionIdentifier
        customData:(nullable NSDictionary<NSString *, id> *)nextActionCustomData;

@end

/**
 *  Wrapper class for async actions
 *
 *  Every async action (`HUBAsyncAction`) is wrapped using this class, and performed using it. The reason for that
 *  is to be able to associate a certain context with an action, without requiring each action implementation to
 *  synthesize a context property.
 */
@interface HUBAsyncActionWrapper : NSObject

/// The action's delegate. See `HUBAsyncActionWrapperDelegate` for more info.
@property (nonatomic, weak, nullable) id<HUBAsyncActionWrapperDelegate> delegate;

/**
 *  Initialize an instance of this class
 *
 *  @param action The action that this object should wrap
 *  @param context The context that the action will be performed using
 */
- (instancetype)initWithAction:(id<HUBAsyncAction>)action context:(id<HUBActionContext>)context HUB_DESIGNATED_INITIALIZER;

/// Perform the underlying action and return the result
- (BOOL)perform;

@end

NS_ASSUME_NONNULL_END
