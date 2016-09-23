#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Mocked gesture recognizer, for use in unit tests only
@interface HUBGestureRecognizerMock : UIGestureRecognizer

/// A value containing any current touch phase of the recognizer. Contains a `HUBTouchPhase` value.
@property (nonatomic, strong, nullable, readonly) NSValue *touchPhaseValue;

@end

NS_ASSUME_NONNULL_END
