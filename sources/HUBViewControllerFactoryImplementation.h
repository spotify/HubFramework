#import "HUBViewControllerFactory.h"
#import "HUBHeaderMacros.h"

@protocol HUBImageLoaderFactory;
@protocol HUBContentReloadPolicy;
@protocol HUBComponentLayoutManager;
@protocol HUBActionHandler;
@class HUBViewModelLoaderFactoryImplementation;
@class HUBFeatureRegistryImplementation;
@class HUBComponentRegistryImplementation;
@class HUBInitialViewModelRegistry;
@class HUBActionRegistryImplementation;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewControllerFactory` API
@interface HUBViewControllerFactoryImplementation : NSObject <HUBViewControllerFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModelLoaderFactory The factory to use to create view model loaders
 *  @param featureRegistry The feature registry to use to retrieve information about registered features
 *  @param componentRegistry The component registry to use in the view controllers that this factory creates
 *  @param initialViewModelRegistry The registry to use to retrieve pre-computed view models for initial content
 *  @param actionRegistry The registry to use to retrieve actions for events occuring in a view controller
 *  @param defaultActionHandler Any user-defined action handler to use for features that don't define their own
 *  @param componentLayoutManager The object that manages layout for components for created view controllers
 *  @param imageLoaderFactory The factory to use to create image loaders
 */
- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                               featureRegistry:(HUBFeatureRegistryImplementation *)featureRegistry
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                                actionRegistry:(HUBActionRegistryImplementation *)actionRegistry
                          defaultActionHandler:(nullable id<HUBActionHandler>)defaultActionHandler
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
                            imageLoaderFactory:(nullable id<HUBImageLoaderFactory>)imageLoaderFactory HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
