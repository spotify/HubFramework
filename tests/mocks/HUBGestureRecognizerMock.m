#import "HUBGestureRecognizerMock.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "HUBTouchPhase.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBGestureRecognizerMock ()

@property (nonatomic, strong, nullable, readwrite) NSValue *touchPhaseValue;

@end

@implementation HUBGestureRecognizerMock

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseBegan);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseMoved);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseEnded);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchPhaseValue = @(HUBTouchPhaseCancelled);
}

@end

NS_ASSUME_NONNULL_END
