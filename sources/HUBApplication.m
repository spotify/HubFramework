#import "HUBApplication.h"

@interface HUBApplication()

@property (nonatomic, strong, readonly) UIApplication *application;

@end

@implementation HUBApplication

- (instancetype)initWithApplication:(UIApplication *)application
{
    NSParameterAssert(application != nil);
    
    self = [super init];
    if (self) {
        _application = application;
    }
    return self;
}

- (UIWindow *)keyWindow
{
    return self.application.keyWindow;
}

- (CGRect)statusBarFrame
{
    return self.application.statusBarFrame;
}

- (BOOL)openURL:(NSURL *)url
{
    return [self.application openURL:url];
}

@end
