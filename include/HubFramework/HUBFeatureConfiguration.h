#import <Foundation/Foundation.h>

@protocol HUBContentProviderFactory;
@protocol HUBViewURIQualifier;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Protocol defining the public API of an object that can used to configure a feature for use with the Hub Framework
 *
 *  A feature is the top-level entity in the Hub Framework, that is used to encapsulate related views into a logical group.
 *  Views that belong to the same feature share a common root view URI as a prefix, as well as content providing logic
 *  and overrides.
 *
 *  You don't conform to this protocol yourself, instead create a new object conforming to this protocol using `HUBFeatureRegistry`,
 *  available on the application's `HUBManager`. You can then change whatever properties you want on the configuration object,
 *  and finally pass it back to the `HUBFeatureRegistry` to register your feature with the Hub Framework.
 */
@protocol HUBFeatureConfiguration <NSObject>

/**
 *  The identifier of the feature
 *
 *  The value of this property is set when creating the feature configuration through `HUBFeatureRegistry`.
 */
@property (nonatomic, copy, readonly) NSString *featureIdentifier;

/**
 *  The root view URI of the feature
 *
 *  The value of this property is set when creating the feature configuration through `HUBFeatureRegistry`.
 */
@property (nonatomic, copy, readonly) NSURL *rootViewURI;

/**
 *  The factories that should be used to create content providers for views of the feature
 *
 *  This array must not be empty when registering the feature. For more information see `HUBContentProviderFactory`.
 */
@property (nonatomic, strong, readonly) NSMutableArray<id<HUBContentProviderFactory>> *contentProviderFactories;

/**
 *  Any identifier of a custom JSON schema to use to parse remote content data
 *
 *  If this property is `nil`, the default Hub Framework JSON schema will be used to parse remote content JSON data
 */
@property (nonatomic, copy, nullable) NSString *customJSONSchemaIdentifier;

/**
 *  Any view URI qualifier that the feature should use
 *
 *  A view URI qualifier can be used to disqualify certain view URIs from behing associated with a feature. For more information
 *  on how use this API, see the documentation for `HUBViewURIQualifier`.
 */
@property (nonatomic, strong, nullable) id<HUBViewURIQualifier> viewURIQualifier;

@end

NS_ASSUME_NONNULL_END
