#import <Foundation/Foundation.h>

@protocol HUBJSONSchema;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of a Hub JSON schema registry
 *
 *  You don't conform to this protocol yourself, instead the application's `HUBManager` has an object conforming
 *  to this protocol attached to it, that enables you to create and register custom JSON schemas for use in the
 *  Hub Framework.
 *
 *  To customize a schema, create one using `-createNewSchema`, then set up the returned schema to match the JSON
 *  format that you are expecting, and finally register it with the registry.
 *
 *  For more information on how Hub Framework JSON schemas work; see `HUBJSONSchema`.
 */
@protocol HUBJSONSchemaRegistry <NSObject>

/**
 *  Create a new JSON schema that can be customized for a custom JSON format
 *
 *  The returned schema comes setup according to the default Hub Framework JSON schema, so you are free to customize
 *  only the parts of it that you need to.
 */
- (id<HUBJSONSchema>)createNewSchema;

/**
 *  Register a custom JSON schema for use with the Hub Framework
 *
 *  @param schema The schema to register
 *  @param identifier The identifier to register the schema for
 *
 *  The identifier that this schema gets registered for must be unique. If another schema has already been registered
 *  for the given identifier, an assert will be triggered. To get the Hub Framework to use your custom schema to parse
 *  any downloaded JSON, set the `customJSONSchemaIdentifier` property on your `HUBFeatureConfiguration` when registering
 *  your feature with the framework.
 */
- (void)registerCustomSchema:(id<HUBJSONSchema>)schema forIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
