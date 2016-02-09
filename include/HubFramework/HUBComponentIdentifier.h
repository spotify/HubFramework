#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A component identifier consists of a namespace and a name and is usually coming from the backend of the form
 *  `namespace:name`.
 */
@interface HUBComponentIdentifier : NSObject <NSCopying>

/// The component namespace
@property (nonatomic, copy, readonly) NSString *componentNamespace;

/// The component name
@property (nonatomic, copy, readonly) NSString *componentName;

/**
 *  Initialize a component identifier
 *
 *  @param componentNamespace The namespace
 *  @param componentName The name
 */
- (instancetype)initWithNamespace:(NSString *)componentNamespace name:(NSString *)componentName NS_DESIGNATED_INITIALIZER;

/**
 * Initialize a component identifier from an identifier string.
 *
 * @param identifierString The identifier
 *
 * The identifier should be of the form `namespace:name`.
 */
- (instancetype)initWithString:(NSString *)identifierString;

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

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
