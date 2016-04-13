#import "HUBJSONSchemaRegistry.h"
#import "HUBHeaderMacros.h"

@class HUBComponentDefaults;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBJSONSchemaRegistry` API
@interface HUBJSONSchemaRegistryImplementation : NSObject <HUBJSONSchemaRegistry>

/// The default JSON schema that is used when a feature has not declared a custom JSON schema identifier
@property (nonatomic, strong, readonly) id<HUBJSONSchema> defaultSchema;

/**
 *  Initialize an instance of this class with a set of component default values
 *
 *  @param componentDefaults The default component values to use when parsing JSON
 */
- (instancetype)initWithComponentDefaults:(HUBComponentDefaults *)componentDefaults HUB_DESIGNATED_INITIALIZER;

/**
 *  Return a custom JSON schema that has been registered for a certain identifier
 *
 *  If a schema does not exist for the given identifier, `nil` is returned.
 */
- (nullable id<HUBJSONSchema>)customSchemaForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
