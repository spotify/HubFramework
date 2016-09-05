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
@interface HUBIdentifier : NSObject <NSCopying>

/// The namespace of the component to use. Will me used to resolve a registered `HUBComponentFactory`.
@property (nonatomic, copy, readonly) NSString *namespacePart;

/// The name of the component to use. Will be sent to the component factory that will create a component.
@property (nonatomic, copy, readonly) NSString *namePart;

/// A string representation of the identifier, in the `namespace:name` format.
@property (nonatomic, copy, readonly) NSString *identifierString;

/**
 *  Initialize an identifier
 *
 *  @param namespacePart The namespace part of the identifier
 *  @param namePart The name part of the identifier
 */
- (instancetype)initWithNamespace:(NSString *)namespacePart
                             name:(NSString *)namePart HUB_DESIGNATED_INITIALIZER;

/**
 *  Compare two identifiers for equality
 *
 *  @param identifier Th identifier to compare this instance to
 *
 *  Returns YES if both the namespace and name parts are equal in both objects.
 */
- (BOOL)isEqualToIdentifier:(HUBIdentifier *)identifier;

@end

NS_ASSUME_NONNULL_END
