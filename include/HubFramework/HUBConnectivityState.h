#import <Foundation/Foundation.h>

/// Enum describing various connectivity states that an application can be in
typedef enum : NSUInteger {
    /// The application is currently online and connected to the Internet
    HUBConnectivityStateOnline,
    /// The application is currently offline and not connected to the Internet
    HUBConnectivityStateOffline
} HUBConnectivityState;
