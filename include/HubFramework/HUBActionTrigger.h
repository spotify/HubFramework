#import <Foundation/Foundation.h>

/// Enum describing various reasons that can cause an action to be triggered
typedef NS_ENUM(NSUInteger, HUBActionTrigger) {
    /// The action was triggered by that a component was selected
    HUBActionTriggerSelection,
    /// The action was triggered manually by a component
    HUBActionTriggerComponent
};
