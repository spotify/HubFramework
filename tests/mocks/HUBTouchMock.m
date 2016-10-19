#import "HUBTouchMock.h"

@implementation HUBTouchMock

- (CGPoint)locationInView:(UIView *)view
{
    return self.location;
}

@end
