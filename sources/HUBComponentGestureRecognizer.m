#import "HUBComponentGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

@implementation HUBComponentGestureRecognizer

#pragma mark - API

- (void)cancel
{
    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark - UIGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch * const touch = [touches anyObject];
    CGPoint const touchLocation = [touch locationInView:self.view];
    
    if (touchLocation.y < 0 || touchLocation.y > CGRectGetHeight(self.view.bounds)) {
        self.state = UIGestureRecognizerStateFailed;
    } else if (touchLocation.x < 0 || touchLocation.x > CGRectGetWidth(self.view.bounds)) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.state != UIGestureRecognizerStateCancelled) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}

@end

NS_ASSUME_NONNULL_END
