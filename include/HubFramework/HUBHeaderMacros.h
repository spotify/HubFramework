#import <Foundation/Foundation.h>

/// Macro that marks an initializer as designated, and also makes the default Foundation initializers unavailable
#define HUB_DESIGNATED_INITIALIZER NS_DESIGNATED_INITIALIZER; \
    + (instancetype)new NS_UNAVAILABLE; \
    - (instancetype)init NS_UNAVAILABLE; \
    - (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
