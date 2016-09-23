#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol adopted by objects that can have touches forwarded to them
@protocol HUBTouchForwardingTarget <NSObject>

/**
 *  Forward a "touches began" event to the target
 *
 *  @param touches The touches that begun
 *  @param event The event to forward
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/**
 *  Forward a "touches moved" event to the target
 *
 *  @param touches The touches that were moved
 *  @param event The event to forward
 */
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/**
 *  Forward a "touches ended" event to the target
 *
 *  @param touches The touches that ended
 *  @param event The event to forward
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/**
 *  Forward a "touches cancelled" event to the target
 *
 *  @param touches The touches that were cancelled
 *  @param event The event to forward
 */
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
