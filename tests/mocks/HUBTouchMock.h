#import <UIKit/UIKit.h>

/// Mocked touch object, for use in unit tests only
@interface HUBTouchMock : UITouch

/// Any mocked location that the touch should return from `locationInView:`
@property (nonatomic) CGPoint location;

@end
