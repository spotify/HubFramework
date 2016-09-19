#import "HUBComponentFallbackHandler.h"
#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class HUBComponentDefaults;

/// Mocked component fallback handler, for use in tests only
@interface HUBComponentFallbackHandlerMock : NSObject <HUBComponentFallbackHandler>

/**
 *  Initialize an instance of this class with a set of component defaults
 *
 *  @param componentDefaults The defaults object to set up this fallback handler's default properties using
 */
- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults HUB_DESIGNATED_INITIALIZER;

/**
 *  Add a fallback component to return for a given category
 *
 *  @param component The component to add
 *  @param category The category to add the component for
 *
 *  The mock will stat returning the given component every time it's asked to create a fallback component for
 *  the given category.
 */
- (void)addFallbackComponent:(id<HUBComponent>)component forCategory:(HUBComponentCategory)category;

@end

NS_ASSUME_NONNULL_END
