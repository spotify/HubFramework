#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A component identifier consists of a namespace and a name, or just a name (with an inferred namespace). Identifiers
 *  can be constructed either programmatically or through a string.
 *
 *  The Hub Framework uses component identifiers to map a certain `HUBComponentModel` to a `HUBComponent` implementation.
 */
@interface HUBComponentIdentifier : NSObject <NSCopying>

/// The namespace of the component to use, or `nil` if the Hub Framework should infer a namespace
@property (nonatomic, copy, readonly) NSString *componentNamespace;

/// The name of the component to use
@property (nonatomic, copy, readonly) NSString *componentName;

/// A string representation of the component identifier, `namespace:name` or `name`.
@property (nonatomic, copy, readonly) NSString *identifierString;

/**
 *  Initialize a component identifier
 *
 *  @param componentNamespace The namespace part of the identifier (or nil if an inferred namespace should be used)
 *  @param componentName The name part of the identifier
 */
- (instancetype)initWithNamespace:(NSString *)componentNamespace
                             name:(NSString *)componentName NS_DESIGNATED_INITIALIZER;

/**
 *  Compare if another component identifier is the same.
 *
 *  @param componentIdentifier The other component identifier.
 *
 *  Returns @YES if namespace and name are equal in both objects.
 */
- (BOOL)isEqualToComponentIdentifier:(HUBComponentIdentifier *)componentIdentifier;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
