#import "HUBHeaderMacros.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  A component identifier is used to match a `HUBComponentModel` to a `HUBComponent` implementation
 *
 *  Component identifiers have two parts; a `namespace` and a `name`. The namespace is used to resolve
 *  which `HUBComponentFactory` to use to create a component for a model, and the name is then passed
 *  to that factory when it's asked to create a component.
 *
 *  You can create component identifiers programmatically, or supply string representations when
 *  using JSON data using the `namespace:name` format.
 */
@interface HUBComponentIdentifier : NSObject <NSCopying>

/// The namespace of the component to use. Will me used to resolve a registered `HUBComponentFactory`.
@property (nonatomic, copy, readonly) NSString *componentNamespace;

/// The name of the component to use. Will be sent to the component factory that will create a component.
@property (nonatomic, copy, readonly) NSString *componentName;

/// A string representation of the component identifier, in the `namespace:name` format.
@property (nonatomic, copy, readonly) NSString *identifierString;

/**
 *  Initialize a component identifier
 *
 *  @param componentNamespace The namespace part of the identifier
 *  @param componentName The name part of the identifier
 *
 *  See the documentation for the properties that match the paramaters for more information.
 */
- (instancetype)initWithNamespace:(NSString *)componentNamespace
                             name:(NSString *)componentName HUB_DESIGNATED_INITIALIZER;

/**
 *  Compare if another component identifier is the same.
 *
 *  @param componentIdentifier The other component identifier.
 *
 *  Returns @YES if namespace and name are equal in both objects.
 */
- (BOOL)isEqualToComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier;

@end

NS_ASSUME_NONNULL_END
