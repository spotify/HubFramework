#import "HUBJSONSchemaRegistry.h"

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchemaRegistry` API
@interface HUBJSONSchemaRegistryImplementation : NSObject <HUBJSONSchemaRegistry>

/// The default JSON schema that is used when a feature has not declared a custom JSON schema identifier
@property (nonatomic, strong, readonly) id<HUBJSONSchema> defaultSchema;

/**
 *  Return a custom JSON schema that has been registered for a certain identifier
 *
 *  If a schema does not exist for the given identifier, `nil` is returned.
 */
- (nullable id<HUBJSONSchema>)customSchemaForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
