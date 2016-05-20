#import "HUBHeaderMacros.h"

@protocol HUBFeatureRegistry;
@protocol HUBComponentRegistry;
@protocol HUBJSONSchemaRegistry;
@protocol HUBViewModelLoaderFactory;
@protocol HUBViewControllerFactory;
@protocol HUBConnectivityStateResolver;
@protocol HUBDataLoaderFactory;
@protocol HUBImageLoaderFactory;
@protocol HUBIconImageResolver;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBComponentFallbackHandler;
@protocol HUBContentOperationFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class is the main entry point into the Hub Framework
 *
 *  An application using the Hub Framework should create an instance of this class,
 *  and retain it in a central location (such as its App Delegate)
 */
@interface HUBManager : NSObject

/// The feature registry used by this Hub Manager. See the documentation for `HUBFeatureRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBFeatureRegistry> featureRegistry;

/// The component registry used by this Hub Manager. See the documentation for `HUBComponentRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;

/// The JSON schema registry used by this Hub Manager. See the documentation for `HUBJSONSchemaRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBJSONSchemaRegistry> JSONSchemaRegistry;

/// The factory used to create view model loaders. See `HUBViewModelLoaderFactory` for more info.
@property (nonatomic, strong, readonly) id<HUBViewModelLoaderFactory> viewModelLoaderFactory;

/// The factory used to create view controllers. See `HUBViewControllerFactory` for more info.
@property (nonatomic, strong, readonly) id<HUBViewControllerFactory> viewControllerFactory;

/**
 *  Initialize an instance of this class with a component fallback handler
 *
 *  @param connectivityStateResolver An object responsible for determining the current connectivity state of the application.
 *  @param imageLoaderFactory A factory that creates image loaders that are used to load images for components
 *  @param iconImageResolver An object responsible for converting icons into renderable images. See `HUBIconImageResolver` for
 *         more information.
 *  @param componentLayoutManager The object to use to manage layout for components, computing margins using layout traits.
 *         See `HUBComponentLayoutManager` for more information.
 *  @param componentFallbackHandler The object to use to fall back to default components in case a component could not be
 *         resolved using the standard mechanism. See `HUBComponentFallbackHandler` for more information.
 *  @param defaultContentReloadPolicy Any default content reload policy to use for features that do not define their own.
 *         A content reload policy determines whenever a view belonging to the feature should have its content reloaded.
 *         If nil, any feature not defining its own reload policy will always be reloaded whenever a view that belongs to
 *         it re-appears. See `HUBContentReloadPolicy` for more information.
 *  @param prependedContentOperationFactory Any content operation factory that should be prepended to the chain of content
 *         operation factories for all views. The operations that this factory produces will therefore always be prepended
 *         to the content loading chain of any view.
 *  @param appendedContentOperationFactory Any content operation factory that should be appended to the chain of content
 *         operation factories for all views. The operations that this factory produces will therefore always be appended
 *         to the content loading chain of any view.
 */
- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                               imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                                iconImageResolver:(id<HUBIconImageResolver>)iconImageResolver
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                         componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                       defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                 prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
                  appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
