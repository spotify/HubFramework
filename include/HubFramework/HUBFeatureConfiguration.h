#import <Foundation/Foundation.h>

@protocol HUBRemoteContentURLResolver;
@protocol HUBRemoteContentProviderFactory;
@protocol HUBLocalContentProviderFactory;
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
 *  The identifier must be unique to a feature.
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
 *  Any remote content URL resolver that the feature should use
 *
 *  If you don't wish to implement your own remote content provider (& factory), you can assign an object conforming to
 *  `HUBRemoteContentURLResolver` to this property. If this is done, the Hub Framework will create a default remote content
 *  provider for your feature (using `HUBDefaultRemoteContentProviderFactory`).
 *
 *  Assigning both this property and `remoteContentProviderFactory` is considered a programmer error and will trigger an assert.
 *
 *  See `HUBRemoteContentURLResolver` for more information.
 */
@property (nonatomic, strong, nullable) id<HUBRemoteContentURLResolver> remoteContentURLResolver;

/**
 *  Any remote content provider factory that the feature should use
 *
 *  If you wish to implement your own remote content provider, create a `HUBRemoteContentProviderFactory` and assign it to this
 *  property. This gives you the ability to perform custom networking code. If all you wish to do is load data from a given HTTP
 *  URL however, consider using a `HUBRemoteContentURLResolver` (by assigning `remoteContentURLResolver`) instead.
 *
 *  Assigning both this property and `remoteContentURLResolver` is considered a programmer error and will trigger an assert.
 *
 *  See `HUBRemoteContentProviderFactory` for more information.
 */
@property (nonatomic, strong, nullable) id<HUBRemoteContentProviderFactory> remoteContentProviderFactory;

/**
 *  Any local content provider factory that the feature should use
 *
 *  If you feature should use local content that is generated in code, create a `HUBLocalContentProviderFactory` and assign it to
 *  this property. This will enable your feature to be usable offline, and is highly recommended when relevant content can be
 *  generated without network access.
 *
 *  See `HUBLocalContentProviderFactory` for more information.
 */
@property (nonatomic, strong, nullable) id<HUBLocalContentProviderFactory> localContentProviderFactory;

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
