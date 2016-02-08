#import <Foundation/Foundation.h>

@protocol HUBComponentModel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol implemented by objects that can provide a fallback component identifier, in
 *  case a component couldn't be found for a certain component identifier.
 *
 *  The reason you need to implement this API is because we don't want to treat an invalid
 *  component identifier in a JSON file (or in local data) to be treated as a fatal error - we
 *  prefer rendering the content in a component other than the intended one rather than not
 *  rendering it at all (or even worse - crashing).
 *
 *  Implement this protocol in a custom object, and inject it when setting up the Hub
 *  Framework's `HUBManager`.
 */
@protocol HUBComponentFallbackHandler <NSObject>

/**
 *  Return the identifier of a component to use as a fallback, if a model is declaring a
 *  `componentIdentifier` that could not be found in the Hub Framework's component registry.
 *
 *  @param model The model for which a component could not be found
 *
 *  @return A fully usable component identifier (including namespace) that the Hub Framework
 *  can use to retrieve a fallback component for the supplied model. Please note that this is
 *  a "last resort" API, if the returned component identifier still couldn't be resolved, an
 *  assert will be triggered, which should be treated as a fatal error.
 */
- (NSString *)fallbackComponentIdentifierForModel:(id<HUBComponentModel>)model;

@end

NS_ASSUME_NONNULL_END
