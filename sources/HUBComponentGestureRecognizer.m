#import "HUBComponentGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

NS_ASSUME_NONNULL_BEGIN

@interface HUBComponentGestureRecognizer ()

@property (nonatomic, assign) CGPoint touchOrigin;
@property (nonatomic, assign) BOOL tapFailed;

@end

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
    
    UITouch * const touch = [touches anyObject];
    self.touchOrigin = [touch locationInView:self.view];
    self.tapFailed = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch * const touch = [touches anyObject];
    CGPoint const touchLocation = [touch locationInView:self.view];
    
    if (touchLocation.y < 0 || touchLocation.y > CGRectGetHeight(self.view.bounds)) {
        self.tapFailed = YES;
        self.state = UIGestureRecognizerStateFailed;
    } else if (touchLocation.x < 0 || touchLocation.x > CGRectGetWidth(self.view.bounds)) {
        self.tapFailed = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (self.tapFailed) {
        self.state = UIGestureRecognizerStateFailed;
    } else if (self.state != UIGestureRecognizerStateCancelled) {
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
