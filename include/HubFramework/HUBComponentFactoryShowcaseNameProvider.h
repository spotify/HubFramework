#import "HUBComponentFactory.h"

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

@end
