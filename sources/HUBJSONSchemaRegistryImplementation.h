#import "HUBJSONSchemaRegistry.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchemaRegistry` API
@interface HUBJSONSchemaRegistryImplementation : NSObject <HUBJSONSchemaRegistry>

/// The default JSON schema that is used when a feature has not declared a custom JSON schema identifier
@property (nonatomic, strong, readonly) id<HUBJSONSchema> defaultSchema;

/**
 *  Initialize an instance of this class with the default component namespace
 *
 *  @param defaultComponentNamespace The default component namespace of this Hub Framework instance
 */
- (instancetype)initWithDefaultComponentNamespace:(NSString *)defaultComponentNamespace NS_DESIGNATED_INITIALIZER;

/**
 *  Return a custom JSON schema that has been registered for a certain identifier
 *
 *  If a schema does not exist for the given identifier, `nil` is returned.
 */
- (nullable id<HUBJSONSchema>)customSchemaForIdentifier:(NSString *)identifier;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
