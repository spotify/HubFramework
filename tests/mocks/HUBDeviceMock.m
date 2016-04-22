#import "HUBDeviceMock.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBDeviceMock

- (NSString *)systemVersion
{
    NSString * const mockedSystemVersion = self.mockedSystemVersion;
    
    if (mockedSystemVersion != nil) {
        return mockedSystemVersion;
    }
    
    return [super systemVersion];
}

@end

NS_ASSUME_NONNULL_END
