#import "HUBHeaderMacros.h"

@protocol HUBFeatureRegistry;
@protocol HUBComponentRegistry;
@protocol HUBActionRegistry;
@protocol HUBJSONSchemaRegistry;
@protocol HUBViewModelLoaderFactory;
@protocol HUBViewControllerFactory;
@protocol HUBComponentShowcaseManager;
@protocol HUBConnectivityStateResolver;
@protocol HUBDataLoaderFactory;
@protocol HUBImageLoaderFactory;
@protocol HUBIconImageResolver;
@protocol HUBActionHandler;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBComponentFallbackHandler;
@protocol HUBContentOperationFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class is the main entry point into the Hub Framework
 *
 *  An application using the Hub Framework should create a single instance of this class and retain it in a central
 *  location (such as its App Delegate). This class exposes the public API of the Hub Framework in a modular fashion,
 *  with each part of the API encapsulated in either a registry or a factory.
 */
@interface HUBManager : NSObject

/// The registry used to register features with the framework. See the documentation for `HUBFeatureRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBFeatureRegistry> featureRegistry;

/// The registry used to register components with the framework. See the documentation for `HUBComponentRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;

/// The registry used to register actions with the framework. See the documentation for `HUBActionRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBActionRegistry> actionRegistry;

/// The registry used to register custom JSON schemas. See the documentation for `HUBJSONSchemaRegistry` for more info.
@property (nonatomic, strong, readonly) id<HUBJSONSchemaRegistry> JSONSchemaRegistry;

/// The factory used to create view model loaders. See `HUBViewModelLoaderFactory` for more info.
@property (nonatomic, strong, readonly) id<HUBViewModelLoaderFactory> viewModelLoaderFactory;

/// The factory used to create view controllers. See `HUBViewControllerFactory` for more info.
@property (nonatomic, strong, readonly) id<HUBViewControllerFactory> viewControllerFactory;

/// The manager used to create component showcases. See `HUBComponentShowcaseManager` for more info.
@property (nonatomic, strong, readonly) id<HUBComponentShowcaseManager> componentShowcaseManager;

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param connectivityStateResolver An object responsible for determining the current connectivity state of the application.
 *  @param componentLayoutManager The object to use to manage layout for components, computing margins using layout traits.
 *         See `HUBComponentLayoutManager` for more information.
 *  @param componentFallbackHandler The object to use to fall back to default components in case a component couldn't be
 *         resolved using the standard mechanism. See `HUBComponentFallbackHandler` for more information.
 *  @param imageLoaderFactory Any custom factory that creates image loaders that are used to load remote images for components.
 *         If nil, a default image loader factory will be used. See `HUBImageLoaderFactory` for more info.
 *  @param iconImageResolver Any object responsible for converting icons into renderable images. If nil, this instance of
 *         the Hub Framework won't support icons. See `HUBIconImageResolver` for more information.
 *  @param defaultActionHandler Any default action handler to use for features that do not define their own. An action handler
 *         enables execution of custom code instead of performing an action. See `HUBActionHandler` for more information.
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
                           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                         componentFallbackHandler:(id<HUBComponentFallbackHandler>)componentFallbackHandler
                               imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory
                                iconImageResolver:(nullable id<HUBIconImageResolver>)iconImageResolver
                             defaultActionHandler:(nullable id<HUBActionHandler>)defaultActionHandler
                       defaultContentReloadPolicy:(nullable id<HUBContentReloadPolicy>)defaultContentReloadPolicy
                 prependedContentOperationFactory:(nullable id<HUBContentOperationFactory>)prependedContentOperationFactory
                  appendedContentOperationFactory:(nullable id<HUBContentOperationFactory>)appendedContentOperationFactory HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
