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
 *  A feature's identifier is mainly used for identifying the feature within the Hub Framework, but also acts as the default value for
 *  logging (it can be overriden in the view model building phase through either JSON or the `HUBLocalContentProvider` API, for any view
 *  that belongs to the feature).
 *
 *  The idenetifier must be unique to a feature.
 */
@property (nonatomic, copy) NSString *featureIdentifier;

/**
 *  The root view URI of the feature
 *
 *  The Hub Framework will consider all views that have this view URI as a prefix to be part of the feature that this
 *  configuration represents. See `HUBViewURIQualifier` for information on how to override this behavior.
 *
 *  The root view URI must be unique to a feature.
 */
@property (nonatomic, copy) NSURL *rootViewURI;

/**
 *  The content provider factory that the feature should use
 *
 *  You can either use a custom object conforming to this protocol, in case you want to implement custom content loading logic.
 *  Another option is to pass a `HUBRemoteContentURLResolver` object when creating a configuration object, to utilize a default
 *  implementation of this property.
 *
 *  See `HUBContentProviderFactory` for more information.
 */
@property (nonatomic, strong) id<HUBContentProviderFactory> contentProviderFactory;

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
