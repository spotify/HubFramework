#import "HUBApplicationMock.h"

@implementation HUBApplicationMock

@synthesize keyWindow = _keyWindow;
@synthesize statusBarFrame = _statusBarFrame;

- (BOOL)openURL:(NSURL *)url
{
    return YES;
}

@end
