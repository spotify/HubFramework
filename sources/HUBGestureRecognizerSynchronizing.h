#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  `HUBGestureRecognizerSynchronizing` object is used to keep track of active `HUBComponentGestureRecognizers` so they
 *  can be performed one at a time. It is passed to `HUBComponentGestureRecognizers` when initialized.
 */
@protocol HUBGestureRecognizerSynchronizing

/**
 *  If this property is set to `YES`, a `HUBComponentGestureRecognizers` that is about to begin handling touch events
 *  should fail.
 *
 *  If this property is set to `NO`, a `HUBComponentGestureRecognizers` that is about to begin handling touch events
 *  should set this flag to `YES` and proceed with handling touch events.
 */
@property (nonatomic, assign, getter=isLocked) BOOL locked;

@end

NS_ASSUME_NONNULL_END
