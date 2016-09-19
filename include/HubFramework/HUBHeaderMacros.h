#import <Foundation/Foundation.h>

/// Macro that marks an initializer as designated, and also makes the default Foundation initializers unavailable
#define HUB_DESIGNATED_INITIALIZER NS_DESIGNATED_INITIALIZER; \
    /** Unavailable. Use the designated initializer instead */ \
    + (instancetype)new NS_UNAVAILABLE; \
    /** Unavailable. Use the designated initializer instead */ \
    - (instancetype)init NS_UNAVAILABLE; \
    /** Unavailable. Use the designated initializer instead */ \
    - (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/// This macro was introduced in Xcode 8, so adding this here for now (if not defined) to support Xcode 7 as well
#ifndef NS_EXTENSIBLE_STRING_ENUM
    #define NS_EXTENSIBLE_STRING_ENUM
#endif
