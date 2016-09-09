#import "HUBActionRegistry.h"
#import "HUBHeaderMacros.h"

@protocol HUBAction;
@protocol HUBActionContext;
@class HUBInitialViewModelRegistry;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBActionRegistry` API
@interface HUBActionRegistryImplementation : NSObject <HUBActionRegistry>

/**
 *  Return an action for a certain context
 *
 *  @param context The context to return an action for
 *
 *  This method will return `nil` if no `HUBActionFactory` was found matching
 *  the given context, or if that factory in turn returned `nil`.
 */
- (nullable id<HUBAction>)actionForContext:(id<HUBActionContext>)context;

@end

NS_ASSUME_NONNULL_END
