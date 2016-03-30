#import <UIKit/UIKit.h>

/**
 *  Macro set to `1` if building with the iOS 9.3 SDK or later.
 */
#define HUB_IOS93_SDK (__IPHONE_OS_VERSION_MAX_ALLOWED >= 90300)

/**
 *  Begin a section where the partial availabilty warnings is ignored by the build system.
 *
 *  Use this macro to silence the compiler after auditing a peice code. Making sure that the code patch is safe even for
 *  deployment targets earlier than when the symbol was introduced.
 *
 *  Must be paired with with a matching `HUB_IGNORE_PARTIAL_AVAILABILTY_END` statement.
 */
#if HUB_IOS93_SDK
    #define HUB_IGNORE_PARTIAL_AVAILABILTY_BEGIN \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wpartial-availability\"")
#else
    #define HUB_IGNORE_PARTIAL_AVAILABILTY_BEGIN
#endif

/**
 *  End a section where the partial availability warnings is ignored.
 *
 *  Must be paired with with a matching `HUB_IGNORE_PARTIAL_AVAILABILTY_BEGIN` statement.
 */
#if HUB_IOS93_SDK
    #define HUB_IGNORE_PARTIAL_AVAILABILTY_END \
        _Pragma("clang diagnostic pop")
#else
    #define HUB_IGNORE_PARTIAL_AVAILABILTY_END
#endif

/**
 *  Load the view for a component if it hasn't been loaded already
 *
 *  @param component The component to load a view for
 *
 *  This function asserts that a view has been loaded after -loadView was sent to the component.
 */
static inline UIView *HUBComponentLoadViewIfNeeded(id<HUBComponent> component) {
    if (component.view != nil) {
        return component.view;
    }
    
    [component loadView];
    
    UIView * const view = component.view;
    NSCAssert(view, @"All components are required to load a view in -loadView");
    return view;
}
