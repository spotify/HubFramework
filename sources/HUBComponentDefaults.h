#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/// Class containing default values that are used as initial property values for component model builders
@interface HUBComponentDefaults : NSObject

/// The default component namespace that all component model builders will initially have
@property (nonatomic, copy, readonly) NSString *componentNamespace;

/// The default compone tname that all component model builders will initially have
@property (nonatomic, copy, readonly) NSString *componentName;

/**
 *  Initialize an instance of this class with its required values
 *
 *  @param componentNamespace The default component namespace that all component model builders will initially have
 *  @param componentName The default component name that all component model builders will initially have
 */
- (instancetype)initWithComponentNamespace:(NSString *)componentNamespace
                             componentName:(NSString *)componentName HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
