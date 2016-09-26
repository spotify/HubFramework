#import <Foundation/Foundation.h>

/// Enum describing various phases of a touch event
typedef NS_ENUM(NSUInteger, HUBTouchPhase) {
    /// The touch begun
    HUBTouchPhaseBegan,
    /// The touch was moved on the screen
    HUBTouchPhaseMoved,
    /// The touch ended (finished successfully)
    HUBTouchPhaseEnded,
    /// The touch was cancelled
    HUBTouchPhaseCancelled
};
