#import <Foundation/Foundation.h>

@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/// Class that manages UI state for a component that has restorable UI state
@interface HUBComponentUIStateManager : NSObject

/**
 *  Save a UI state for a component, for a certain model
 *
 *  @param state The UI state to save
 *  @param componentModel The component model to associate the state with
 */
- (void)saveUIState:(id)state forComponentModel:(id<HUBComponentModel>)componentModel;

/**
 *  Restore a previously saved UI state for a component, for a certain model
 *
 *  @param componentModel The component model to return a UI state for
 */
- (nullable id)restoreUIStateForComponentModel:(id<HUBComponentModel>)componentModel;

/**
 *  Remove a previously saved UI state for a component, for a certain model
 *
 *  @param componentModel The component model to remove a saved UI state for
 */
- (void)removeSavedUIStateForComponentModel:(id<HUBComponentModel>)componentModel;

@end

NS_ASSUME_NONNULL_END
