#import "HUBActionContextImplementation.h"

NS_ASSUME_NONNULL_BEGIN

/// Category adding convenience APIs for use in unit tests only
@interface HUBActionContextImplementation (Testing)

/**
 *  Create a context to use in tests
 *
 *  @param actionNamespace The action namespace of the context to create
 *  @param actionName The action name of the context to create
 */
+ (instancetype)contextForTestingWithActionNamespace:(NSString *)actionNamespace
                                                name:(NSString *)actionName;

@end

NS_ASSUME_NONNULL_END
