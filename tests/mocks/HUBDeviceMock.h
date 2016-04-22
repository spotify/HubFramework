#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Mocked device, for use in tests only
@interface HUBDeviceMock : UIDevice

/// The system version that the device should act like it's running
@property (nonatomic, copy, nullable) NSString *mockedSystemVersion;

@end

NS_ASSUME_NONNULL_END
