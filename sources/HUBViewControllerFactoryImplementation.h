#import "HUBViewControllerFactory.h"
#import "HUBHeaderMacros.h"

@protocol HUBImageLoaderFactory;
@protocol HUBComponentLayoutManager;
@class HUBViewModelLoaderFactoryImplementation;
@class HUBComponentRegistryImplementation;
@class HUBInitialViewModelRegistry;

NS_ASSUME_NONNULL_BEGIN

/// Concrete implementation of the `HUBViewControllerFactory` API
@interface HUBViewControllerFactoryImplementation : NSObject <HUBViewControllerFactory>

/**
 *  Initialize an instance of this class with its required dependencies
 *
 *  @param viewModelLoaderFactory The factory to use to create view model loaders
 *  @param imageLoaderFactory The factory to use to create image loaders
 *  @param componentRegistry The component registry to use in the view controllers that this factory creates
 *  @param initialViewModelRegistry The registry to use to retrieve pre-computed view models for initial content
 *  @param componentLayoutManager The object that manages layout for components for created view controllers
 */
- (instancetype)initWithViewModelLoaderFactory:(HUBViewModelLoaderFactoryImplementation *)viewModelLoaderFactory
                            imageLoaderFactory:(id<HUBImageLoaderFactory>)imageLoaderFactory
                             componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
                      initialViewModelRegistry:(HUBInitialViewModelRegistry *)initialViewModelRegistry
                        componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager HUB_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
