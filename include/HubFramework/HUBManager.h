#import <Foundation/Foundation.h>

@protocol HUBFeatureRegistry;
@protocol HUBComponentRegistry;
@protocol HUBJSONSchemaRegistry;
@protocol HUBViewModelLoaderFactory;
@protocol HUBViewControllerFactory;
@protocol HUBConnectivityStateResolver;
@protocol HUBImageLoaderFactory;
@class HUBComponentIdentifier;

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
 *  @param connectivityStateResolver An object responsible for determining the current connectivity state of
 *         the application. This object will be retained.
 *  @param imageLoaderFactory A factory that creates image loaders that are used to load images for components
 *  @param defaultComponentNamespace The component namespace that all component models created using this instance of the
 *         Hub Framework will initially have. This namespace can be overriden by any content provider, using either JSON
 *         data or by using a `HUBComponentModelBuilder` directly. A `HUBComponentFactory` must be registered for this
 *         namespace before any view controllers are created through the Hub Framework. This namespace will also be used
 *         as a fallback, in case an assigned namespace couldn't be resolved.
 *  @param fallbackComponentName The component name to use in case a content provider supplied an unknown component name.
 *         This name will be resolved using the `HUBComponentFactory` for `defaultComponentNamespace` as a last line of
 *         defense and must always result in a component being created.
 */
- (instancetype)initWithConnectivityStateResolver:(id<HUBConnectivityStateResolver>)connectivityStateResolver
                               imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                        defaultComponentNamespace:(NSString *)defaultComponentNamespace
                            fallbackComponentName:(NSString *)fallbackComponentName NS_DESIGNATED_INITIALIZER;

#pragma mark - Unavailable initializers

/// This class needs to be initialized with its designated initializer
- (instancetype)init NS_UNAVAILABLE;

/// This class needs to be initialized with its designated initializer
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
