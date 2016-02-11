
/**
 *  Begin a section where the partial availabilty warnings is ignored by the build system.
 *
 *  Use this macro to silence the compiler after auditing a peice code. Making sure that the code patch is safe even for
 *  deployment targets earlier than when the symbol was introduced.
 *
 *  Must be paired with with a matching `HUB_IGNORE_PARTIAL_AVAILABILTY_END` statement.
 */
#define HUB_IGNORE_PARTIAL_AVAILABILTY_BEGIN \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wpartial-availability\"")

/**
 *  End a section where the partial availability warnings is ignored.
 *
 *  Must be paired with with a matching `HUB_IGNORE_PARTIAL_AVAILABILTY_BEGIN` statement.
 */
#define HUB_IGNORE_PARTIAL_AVAILABILTY_END \
_Pragma("clang diagnostic pop")
