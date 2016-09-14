#import "HUBActionRegistry.h"
#import "HUBHeaderMacros.h"

@protocol HUBAction;
@class HUBIdentifier;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBActionRegistry` API
@interface HUBActionRegistryImplementation : NSObject <HUBActionRegistry>

/// The action that should be performed whenever a selection event occured
@property (nonatomic, strong, readonly) id<HUBAction> selectionAction;

/**
 *  Create an instance of this class with the default selection action
 *
 *  To be able to specify which selection action to use (useful for tests), use this class'
 *  designated initializer instead of this class constructor.
 */
+ (instancetype)registryWithDefaultSelectionAction;

/**
 *  Initialize an instance of this class with a selection action
 *
 *  @param selectionAction The action to be performed whenever a selection event occurs
 */
- (instancetype)initWithSelectionAction:(id<HUBAction>)selectionAction HUB_DESIGNATED_INITIALIZER;

/**
 *  Return an action for a certain identifier
 *
 *  @param identifier The identifier to return an action for
 *
 *  This method will return `nil` if no `HUBActionFactory` was found matching
 *  the given identifier's namespace, or if that factory in turn returned `nil`.
 */
- (nullable id<HUBAction>)createCustomActionForIdentifier:(HUBIdentifier *)identifier;

@end

NS_ASSUME_NONNULL_END
