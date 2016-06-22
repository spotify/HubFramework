#import "HUBComponentFactory.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended `HUBComponentFactory` protocol that adds the ability to provide component names to a showcase
 *
 *  Use this protocol when you want to provide an array of supported component names to be included when
 *  `showcaseableComponentIdentifiers` is requested from the application's `HUBComponentRegistry`.
 *
 *  The Hub Framework does not provide any built-in functionality for showcases, besides providing the
 *  component identifiers that have been declared as showcasable. Instead, it's up to each API user to
 *  build showcase functionality on top of this API.
 *
 *  For more information about component factories, see `HUBComponentFactory`.
 */
@protocol HUBComponentFactoryShowcaseNameProvider <HUBComponentFactory>

/// An array of component names that should be included in a component showcase
@property (nonatomic, strong, readonly) NSArray<NSString *> *showcaseableComponentNames;

/**
 *  Return a human readable name for a component that can be displayed in a showcase
 *
 *  @param componentName The name of the component to return a showcase name for
 *
 *  @return A component name that can be displayed in a showcase UI, or nil if the
 *          name was unrecognized by this component factory.
 */
- (nullable NSString *)showcaseNameForComponentName:(NSString *)componentName;

@end

NS_ASSUME_NONNULL_END
